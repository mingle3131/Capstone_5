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
    struct bidInfo{
        uint80 bidAmount; // 입찰액
        uint80 bidSecurity; // 보증금
        uint64 bidTime; //입찰시각
    } //입찰정보 구조체
    struct tradeInfo{
        uint80 highestAmount; //최고가액
        uint64 highestTime; //최고가 낙찰일자
        address winner; // 현재기준 낙찰자
        uint32 dueDate; //낙찰자 납부기한
    }
    mapping(uint64=>mapping(address=>bidInfo)) private bidInfos; //거래번호 -> 입찰자 -> 입찰구조체
    mapping(uint64=>uint256[2][]) private cryptogram; // 거래번호 -> 암호화데이터 저장 (약 50바이트)
    mapping(uint64=>tradeInfo) private tradeInfos;

    mapping(address => uint256) private userBalance; //사용자가 현재 사용가능한 금액
    
    mapping(uint64 => address[]) private bidderList; // 거래번호별 입찰자목록 저장 (보증금 환불과 대금미납시 새로운 낙찰자 선정을 원활하게하기위함)

    mapping(uint64 => mapping(address=>bool) ) private hasBid; //이미 입찰한 매물인지 체크 용도
        
    uint64[] private tradeNumList;  //  자동화 순회를 위한 거래 번호 저장 배열

    uint256 proceeds = 0; //경매 낙찰로 컨트랙트에 귀속된 금액

    enum ActionType { DEPOSIT, WITHDRAW, REFUND, BID }    

    mapping(address => uint256) public nonces;
    
    uint256 public lastUpkeepTime;
    uint256 public upkeepInterval = 1 days; // upkeepInterval 간격으로 refund함수 반복

    
    using ECDSA for bytes32;
    
    // 경매 이벤트 로그 (나중에 조회하기위함)
    event BidEvents(uint64 tradeNum, address bidder, uint80 amount, ActionType action);

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
    function putCryptogram(uint256 _P1, uint256 _P2, uint64 _tradeNum, address _bidder, uint80 _security, uint256 _nonce, bytes memory signature) public onlyOwner()
    {
        require(!hasBid[_tradeNum][_bidder], "Already bid on this trade");
        uint256 userBal = userBalance[_bidder];
        uint256 userNonce = nonces[_bidder];
        require(_security <= userBal, "Not enough balance");
        require(_nonce == userNonce, "Invalid nonce");
        require(verifySignature(_tradeNum, _security, _bidder, _nonce, signature), "Invalid Signature");
        
        cryptogram[_tradeNum].push([_P1, _P2]);
        
        userBalance[_bidder] = userBal - _security;
        bidderList[_tradeNum].push(_bidder);
        hasBid[_tradeNum][_bidder] = true;
        nonces[_bidder] = userNonce + 1;
    }
//백엔드에서 DES암호화한 입찰정보를 저장
    
    function getCryptogram(uint64 _tradeNum) external view returns (uint256[2][] memory) 
    {
        return cryptogram[_tradeNum];
    }// 백엔드에서 입찰정보를 다시 불러와 복호화



    function getEthSignedMessageHash(bytes32 messageHash) public pure returns (bytes32) 
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    //서명 확인용 함수 (가스 서버 부담위함)
    function verifySignature(uint64 tradeNum, uint80 security, address user, uint256 nonce, bytes memory signature) public pure returns (bool) 
    {
        bytes32 hash = keccak256(abi.encodePacked(tradeNum, security, user, nonce));
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
    function inputDecrypt(uint64 _tradeNum, uint80 _amount, uint80 _security, address _bidder, uint64 _bidTime, uint32 dueDate) external onlyOwner()
    {
        if (bidderList[_tradeNum].length == 0) {
        tradeNumList.push(_tradeNum);
         } //첫 입찰일시 활성화된 거래목록에 추가
        bidInfos[_tradeNum][_bidder].bidAmount = _amount;
        bidInfos[_tradeNum][_bidder].bidSecurity = _security;
        bidInfos[_tradeNum][_bidder].bidTime = _bidTime;
        if(_amount >= tradeInfos[_tradeNum].highestAmount && (_bidTime < tradeInfos[_tradeNum].highestTime || tradeInfos[_tradeNum].highestTime == 0))
        {
            tradeInfos[_tradeNum].highestAmount = _amount;
            tradeInfos[_tradeNum].highestTime = _bidTime;
            tradeInfos[_tradeNum].winner = _bidder;
        }
        if(tradeInfos[_tradeNum].dueDate==0)
        tradeInfos[_tradeNum].dueDate=dueDate;

        emit BidEvents(_tradeNum, _bidder, _amount, ActionType.BID);
    }


    //거래성사시 예치금 환불해주는함수
    function EscrowRefund(uint64 _tradeNum) public onlyOwner()
    {
        address winner = tradeInfos[_tradeNum].winner;
        // proceeds에 최고 입찰액 추가
        proceeds += tradeInfos[_tradeNum].highestAmount;
        // 나머지 입찰자들에게 환불 
        uint256 bidderNum=bidderList[_tradeNum].length;
        for (uint256 i = 0; i < bidderNum; i++) {
            address bidder = bidderList[_tradeNum][i];
            if (bidder != winner) {
                uint80 amount = bidInfos[_tradeNum][bidder].bidSecurity;
                userBalance[bidder] += amount;
                bidInfos[_tradeNum][bidder].bidSecurity=0;
                emit BidEvents(_tradeNum, bidder, amount, ActionType.REFUND);
                }
                }
                //낙찰자 선정로직을 입찰과정으로 옮기는것이 좋아보임 => 루프 없이 현재 최고가만 비교하게끔
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
