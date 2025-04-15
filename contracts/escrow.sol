// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface KeeperCompatibleInterface {
    function checkUpkeep(bytes calldata checkData) external view returns (bool upkeepNeeded, bytes memory performData);
    function performUpkeep(bytes calldata performData) external;
}


contract escrow is Ownable, KeeperCompatibleInterface{

    mapping(uint64 => mapping(address => uint256)) private bidsMap;  // 거래번호 -> 입찰자 -> 입찰가
    mapping(uint64 => mapping(address => uint256)) private bidSecurity;  // 거래번호 -> 입찰자 -> 보증금
    mapping(uint64 => mapping(address => uint256)) private bidtime;  // 거래번호 -> 입찰자 -> 입찰시각
    mapping(address => uint256) private userBalance; //사용자가 현재 사용가능한 금액
    mapping(uint64 => address[]) private bidderList; // 거래번호별 입찰자목록 저장
    mapping(uint64 => mapping(address => uint256)) private paymentDueTime; //낙찰자 납부기한

    

    uint256 proceeds = 0; //경매 낙찰로 컨트랙트에 귀속된 금액

    enum ActionType { DEPOSIT, WITHDRAW, REFUND, BID }

    mapping(address => uint256) public nonces;
    
    uint256 public lastUpkeepTime;
    uint256 public upkeepInterval = 1 days; // upkeepInterval 간격으로 refund함수 반복

    //  자동화 순회를 위한 거래 번호 저장 배열
    uint64[] private tradeNumList;

    
    using ECDSA for bytes32;
    
    // 경매 이벤트 로그 (나중에 조회하기위함)
    event BidEvents(uint64 tradeNum, ActionType action);

    //내부 금액 이동 이벤트 로그
    event Transactions(ActionType action); 


    // 아비트럼에서는 이더리움/원화 환율을 못가져옴 -> 이더/달러 달러/원화 가져와서 이중으로 환산함
    AggregatorV3Interface internal ethUsdFeed; //이더리움 / 달러 환율
    AggregatorV3Interface internal usdKrwFeed; //달러 / 원화 환율 


    constructor() Ownable(msg.sender) {
        // 현재 block.timestamp를 기준으로, 오늘 자정(한국시간)을 UTC 기준으로 보정
    uint256 nowUTC = block.timestamp;
    uint256 offset = 9 hours;

    // UTC 기준의 오늘 00:00 (KST 기준)
    lastUpkeepTime = ((nowUTC + offset) / 1 days) * 1 days - offset;
    }

    
    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) 
    {
        upkeepNeeded = block.timestamp >= lastUpkeepTime + upkeepInterval;
        performData = "";
    }

    
    function performUpkeep(bytes calldata) external override {
        require(block.timestamp >= lastUpkeepTime + upkeepInterval, "Too early");
        lastUpkeepTime = block.timestamp;
        
        uint256 i = 0;
        while (i < tradeNumList.length) {
            uint64 tradeNum = tradeNumList[i];
            // 입찰자가 없으면 나중에 다시 확인하므로 그대로 둠
            if (bidderList[tradeNum].length == 0) {
                i++;
                continue;
                }
            // 입찰자 있으면 환불 처리 후 리스트에서 제거
            EscrowRefund(tradeNum);
            // swap and pop
            tradeNumList[i] = tradeNumList[tradeNumList.length - 1];
            tradeNumList.pop();
            // i는 증가하지 않음 → 새로 swap된 요소 검사
            }
    }





    function getEthSignedMessageHash(bytes32 messageHash) public pure returns (bytes32) 
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    //서명 확인용 함수 (가스 서버 부담위함)
    function verifySignature(uint64 tradeNum, uint256 amount, uint security, address user, uint256 nonce, bytes memory signature) public pure returns (bool) 
    {
        bytes32 hash = keccak256(abi.encodePacked(tradeNum, amount, security, user, nonce));
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
    // amount = 입금할 금액 
    function EscrowDeposit(uint256 amount) external payable 
    {
        //계좌에 이더가 충분하지 않을시
        require(msg.value == amount, "Send required ETH");

        userBalance[msg.sender] += msg.value;
        emit Transactions(ActionType.DEPOSIT);
    }


    //경매 입찰 함수
    function Bid(uint64 tradeNum, uint256 amount, uint256 security, address bidder, uint256 nonce, bytes memory signature) external
    {
        //amount = 입찰가 security= 보증금
        require(verifySignature(tradeNum, amount, security, bidder, nonce, signature), "Invalid signature");
        require(nonce == nonces[bidder], "Invalid nonce");
        nonces[bidder] += 1;

        require(security <= userBalance[bidder], "Not enough balance");
        require(bidsMap[tradeNum][bidder] == 0, "Already bid"); //입찰은 거래당 1회만 가능

        if (bidderList[tradeNum].length == 0) {
        tradeNumList.push(tradeNum);
    }

        bidSecurity[tradeNum][bidder] = security; //보증금 기록
        bidsMap[tradeNum][bidder]=amount; //입찰가 기록
        userBalance[bidder] -= security; //보증금만큼 사용가능금액 차감
        bidderList[tradeNum].push(bidder); //입찰자 목록에 추가
        bidtime[tradeNum][bidder] = block.timestamp; //입찰시각 기록

        emit BidEvents(tradeNum, ActionType.BID);
    }


    //거래성사시 예치금 환불해주는함수
    function EscrowRefund(uint64 tradeNum) internal
    {
        uint256 highestBid = 0;
        address winner;
        address[] memory bidders = bidderList[tradeNum];
        uint256 len=bidders.length;
        for (uint256 i = 0; i < len; i++) {
            address bidder = bidders[i];
            uint256 bidAmount = bidsMap[tradeNum][bidder];
                if (bidAmount >= highestBid) {
                    if(bidAmount!=highestBid){
                    highestBid = bidAmount;
                    winner = bidder;
                    }
                    else{
                        if (bidtime[tradeNum][winner]>bidtime[tradeNum][bidder]){
                            highestBid = bidAmount;
                            winner = bidder;
                            }
                    }
                    }
                    }
        // proceeds에 최고 입찰액 추가
        proceeds += highestBid;
        // 나머지 입찰자들에게 환불 
        for (uint256 i = 0; i < len; i++) {
            address bidder = bidders[i];
            if (bidder != winner) {
                uint256 refundAmount = bidsMap[tradeNum][bidder];
                userBalance[bidder] += refundAmount;
                emit BidEvents(tradeNum, ActionType.REFUND);
                }
                delete bidsMap[tradeNum][bidder];
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

    emit Transactions(ActionType.WITHDRAW);
    }

    //경매 운영자가 컨트랙트에 귀속된 금액 회수하는함수
    function Collectproceeds() external payable onlyOwner
    {
        require(proceeds > 0, "Not enough balance");
        uint256 amount=proceeds;
        proceeds = 0; 
        payable(owner()).transfer(amount);
        emit Transactions(ActionType.WITHDRAW);
    }

    function viewMyDeposits() external view returns (uint256)
    {
        return userBalance[msg.sender];
    }
}
