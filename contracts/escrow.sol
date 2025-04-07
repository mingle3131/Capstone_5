// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";



contract escrow is Ownable{

    mapping(uint64 => mapping(address => uint256)) public bidsMap;  // 거래번호 -> 입찰자 -> 입찰 보증금 
    mapping(address => uint256) public userBalance; //사용자가 현재 사용가능한 금액
    mapping(uint64 => address[]) bidderList; // 거래번호별 입찰자목록 저장
    uint256 proceeds = 0; //경매 낙찰로 컨트랙트에 귀속된 금액
    enum ActionType { DEPOSIT, WITHDRAW, REFUND, BID }
    mapping(address => uint256) public nonces;


    using ECDSA for bytes32;
    
    // 경매 이벤트 로그 (나중에 조회하기위함)
    event BidEvents(address indexed from, uint256 amount, uint256 timestamp, uint64 tradeNum, ActionType action);

    //내부 금액 이동 이벤트 로그
    event Transactions(address indexed user, uint256 amount, uint256 timestamp, ActionType action); 


    // 아비트럼에서는 이더리움/원화 환율을 못가져옴 -> 이더/달러 달러/원화 가져와서 이중으로 환산함
    AggregatorV3Interface internal ethUsdFeed; //이더리움 / 달러 환율
    AggregatorV3Interface internal usdKrwFeed; //달러 / 원화 환율 


    constructor() Ownable(msg.sender) {}


    function getEthSignedMessageHash(bytes32 messageHash) public pure returns (bytes32) 
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    //서명 확인용 함수 (가스 서버 부담위함)
    function verifySignature(uint64 tradeNum, uint256 amount, address user, uint256 nonce, bytes memory signature) public pure returns (bool) 
    {
        bytes32 hash = keccak256(abi.encodePacked(tradeNum, amount, user, nonce));
        bytes32 ethSignedHash = getEthSignedMessageHash(hash);
        address recovered = ECDSA.recover(ethSignedHash, signature);


    return recovered == user;
    }
    function verifySignatureForWithdraw(uint256 amount, address user, uint256 nonce, bytes memory signature) public pure returns (bool) 
    {
        bytes32 hash = keccak256(abi.encodePacked(amount, user, nonce));
        bytes32 ethSignedHash = getEthSignedMessageHash(hash);
        address recovered = ECDSA.recover(ethSignedHash, signature);


    return recovered == user;
    }

    //계좌 잔액 반환
    function getBalance() public view returns (uint256) 
    {
        return address(this).balance;
        // 이함수는 eth 가 아니라 wei 양을 반환함 ( 1 wei = 10^-18 eth)
        // 프론트엔드에서 표시할거면 따로 바꿔야함
    }


    //컨트랙트로 입금하는 함수
    // amount = 입금할 금액 from = 보내는 사람 주소 (로그인 데이터에서 가져올것)
    function EscrowDeposit(uint256 amount) external payable 
    {
        //계좌에 이더가 충분하지 않을시
        require(msg.value == amount, "Send required ETH");

        userBalance[msg.sender] += msg.value;
        emit Transactions(msg.sender, msg.value, block.timestamp, ActionType.DEPOSIT);
    }


    //경매 입찰 함수
    function Bid(uint64 tradeNum, uint256 amount, address bidder, uint256 nonce, bytes memory signature) external
    {
        require(verifySignature(tradeNum, amount, bidder, nonce, signature), "Invalid signature");
        require(nonce == nonces[bidder], "Invalid nonce");
        nonces[bidder] += 1;

        require(amount <= userBalance[bidder], "Not enough balance");
        require(bidsMap[tradeNum][bidder] == 0, "Already bid"); //입찰은 거래당 1회만 가능

        bidsMap[tradeNum][bidder] += amount;
        userBalance[bidder] -= amount;
        bidderList[tradeNum].push(bidder);

        emit BidEvents(bidder, amount, block.timestamp, tradeNum, ActionType.BID);
        emit Transactions(bidder, amount, block.timestamp, ActionType.BID);
    }


    //거래성사시 예치금 환불해주는함수
    function EscrowRefund(uint64 tradeNum) external onlyOwner 
    {
        uint256 highestBid = 0;
        address winner;
        address[] memory bidders = bidderList[tradeNum];
        for (uint256 i = 0; i < bidders.length; i++) {
            address bidder = bidders[i];
            uint256 bidAmount = bidsMap[tradeNum][bidder];
                if (bidAmount > highestBid) {
                    highestBid = bidAmount;
                    winner = bidder;
                    }
                    }
        // proceeds에 최고 입찰액 추가
        proceeds += highestBid;
        // 나머지 입찰자들에게 환불 
        for (uint256 i = 0; i < bidders.length; i++) {
            address bidder = bidders[i];
            if (bidder != winner) {
                uint256 refundAmount = bidsMap[tradeNum][bidder];
                userBalance[bidder] += refundAmount;
                emit Transactions(bidder, refundAmount, block.timestamp, ActionType.REFUND);
                emit BidEvents(bidder, refundAmount, block.timestamp, tradeNum, ActionType.REFUND);
                }
                // 입찰 기록 초기화
                bidsMap[tradeNum][bidder] = 0;
                }
    }


    //예치금액 출금하는함수
    function Withdraw(uint256 amount, address to, uint256 nonce, bytes memory signature) external 
    {
    require(verifySignatureForWithdraw(amount, to, nonce, signature), "Invalid signature");
    require(nonce == nonces[to], "Invalid nonce");
    nonces[to] += 1;
    require(userBalance[to] >= amount, "Insufficient balance");

    userBalance[to] -= amount;
    payable(to).transfer(amount);

    emit Transactions(to, amount, block.timestamp, ActionType.WITHDRAW);
    }

    //경매 운영자가 컨트랙트에 귀속된 금액 회수하는함수
    function Collectproceeds() external payable onlyOwner
    {
        require(proceeds > 0, "Not enough balance");
        payable(owner()).transfer(proceeds);
        emit Transactions(owner(), proceeds, block.timestamp, ActionType.WITHDRAW);
        proceeds = 0; 
    }

    function viewMyDeposits() external view returns (uint256)
    {
        return userBalance[msg.sender];
    }
    
}
