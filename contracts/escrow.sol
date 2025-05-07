// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

interface KeeperCompatibleInterface {
    function checkUpkeep(bytes calldata checkData) external view returns (bool upkeepNeeded, bytes memory performData);
    function performUpkeep(bytes calldata performData) external;
}


contract escrow is Ownable, KeeperCompatibleInterface, ERC721URIStorage{
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

    mapping(uint64=>mapping(address=>bool)) private additionalBid; // 대금미납시 경매 참여 여부

    mapping(uint64=>mapping(address=>uint80)) private winnerPayment; // 거래번호 -> 낙찰자 -> 납부금액 

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


    constructor() Ownable(msg.sender) ERC721("EscrowNFT", "ESN"){ // EscrowNFT 자리에 nft 이름 esn자리에 심볼 입력
        // 현재 block.timestamp를 기준으로, 오늘 자정(한국시간)을 UTC 기준으로 보정
    uint256 nowUTC = block.timestamp;
    uint256 offset = 9 hours;

    // UTC 기준의 오늘 00:00 (KST 기준)
    lastUpkeepTime = ((nowUTC + offset) / 1 days) * 1 days - offset;
    }

    
    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) {
    uint64[] memory temp = new uint64[](tradeNumList.length);
    uint256 count = 0;

    for (uint i = 0; i < tradeNumList.length; i++) {
        uint64 tradeNum = tradeNumList[i];
        tradeInfo memory info = tradeInfos[tradeNum];

        if (
            info.winner != address(0) &&
            info.dueDate != 0 &&
            block.timestamp > info.dueDate
        ) {
            temp[count] = tradeNum;
            count++;
        }
    }

    if (count > 0) {
        // 배열 크기 절단
        uint64[] memory trimmed = new uint64[](count);
        for (uint i = 0; i < count; i++) {
            trimmed[i] = temp[i];
        }
        return (true, abi.encode(trimmed));
    }

    return (false, "");
    }

    
    function performUpkeep(bytes calldata performData) external override {
    uint64[] memory expiredTradeNums = abi.decode(performData, (uint64[]));

    for (uint i = 0; i < expiredTradeNums.length; i++) {
        uint64 tradeNum = expiredTradeNums[i];
        tradeInfo storage info = tradeInfos[tradeNum];

        if (info.winner != address(0) && info.dueDate != 0 && block.timestamp > info.dueDate) 
        {
            checkPayment(tradeNum);
        }
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

    function confirmBid(uint64 _tradeNum) public onlyOwner() returns (address , uint80 ){//낙찰자를 최종적으로 확정하고 납부할 금액을 산정
     address winner = tradeInfos[_tradeNum].winner;
     uint80 payAmount = tradeInfos[_tradeNum].highestAmount-bidInfos[_tradeNum][winner].bidSecurity;
     winnerPayment[_tradeNum][winner]=payAmount;
     return (winner, payAmount);
    }


    function getEthSignedMessageHash(bytes32 messageHash) public pure returns (bytes32) 
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    //서명 확인용 함수 (가스 서버 부담위함)
    function verifySignature(uint64 tradeNum, uint80 amount, address user, uint256 nonce, bytes memory signature) public pure returns (bool) 
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
    // amount = 입금할 금액 
    function EscrowDeposit(uint256 amount) external payable 
    {
        //계좌에 이더가 충분하지 않을시
        require(msg.value == amount, "Send required ETH");

        userBalance[msg.sender] += msg.value;
        emit Transactions(ActionType.DEPOSIT);
    }




    //거래종료시 예치금 환불해주는함수
    function EscrowRefund(uint64 _tradeNum) public onlyOwner()
    {
        address winner = tradeInfos[_tradeNum].winner;
        // proceeds에 최고 입찰액 추가
        proceeds += tradeInfos[_tradeNum].highestAmount;
        // 나머지 입찰자들에게 환불 
        uint256 bidderNum=bidderList[_tradeNum].length;
        for (uint256 i = 0; i < bidderNum; i++) {
            address bidder = bidderList[_tradeNum][i];
            if (bidder != winner && !additionalBid[_tradeNum][bidder]) {
                uint80 amount = bidInfos[_tradeNum][bidder].bidSecurity;
                userBalance[bidder] += amount;
                bidInfos[_tradeNum][bidder].bidSecurity=0;
                emit BidEvents(_tradeNum, bidder, amount, ActionType.REFUND);
                }
                }
    }

    //대금 납부 함수
    function payForAward(uint80 _amount, uint64 _tradeNum, address _from, uint256 nonce, bytes memory signature) public onlyOwner
    {
        uint80 goalPayment = tradeInfos[_tradeNum].highestAmount-bidInfos[_tradeNum][_from].bidSecurity;
        uint80 curPayment = winnerPayment[_tradeNum][_from];
        require(verifySignature( _tradeNum, _amount, _from, nonce, signature),"Invalid Signature");
        require(userBalance[_from] >= _amount, "Insufficient balance");
        require(tradeInfos[_tradeNum].winner==_from,"Only winner can pay for bid");
        require(curPayment+_amount<goalPayment,"payment exceed");
        userBalance[_from]-=_amount;
        winnerPayment[_tradeNum][_from]+=_amount;
    }
    
    //대금납부 확인함수
    function checkPayment(uint64 _tradeNum) internal
    {
        address winner=tradeInfos[_tradeNum].winner;
        uint80 payment = winnerPayment[_tradeNum][winner];
        uint80 goal = tradeInfos[_tradeNum].highestAmount-bidInfos[_tradeNum][winner].bidSecurity;
        if (payment==goal)
        {
            proceeds+=winnerPayment[_tradeNum][winner];
            winnerPayment[_tradeNum][winner]=0;
            EscrowRefund(_tradeNum);
        }
        else
        {
            handleUnpaidWinner(_tradeNum, winner);
        }
    }

    //대금미납시 추가경매 진행 신청
    function markAdditionalBid(uint64 _tradeNum, address _bidder) external onlyOwner 
    {
    additionalBid[_tradeNum][_bidder] = true;
    }


    //대금미납시 진행
    function handleUnpaidWinner(uint64 _tradeNum, address prevWinner) internal 
    {
    address[] memory bidders = bidderList[_tradeNum];
    address newWinner;
    uint80 newHighest = 0;
    uint64 newTime = 0;

    for (uint i = 0; i < bidders.length; i++) {
        address bidder = bidders[i];
        bidInfo memory info = bidInfos[_tradeNum][bidder];

        if (
            bidder != prevWinner &&
            additionalBid[_tradeNum][bidder] &&
            info.bidAmount > newHighest
        ) {
            if (
                info.bidAmount > newHighest || 
                (info.bidAmount == newHighest && info.bidTime < newTime)
            ) {
                newHighest = info.bidAmount;
                newWinner = bidder;
                newTime = info.bidTime;
            }
        }
    }

    if (newWinner != address(0)) {
        tradeInfos[_tradeNum].winner = newWinner;
        tradeInfos[_tradeNum].highestAmount = newHighest;
        tradeInfos[_tradeNum].highestTime = newTime;

        // 정시 기준 30일 추가
        uint256 nowUTC = block.timestamp;
        uint256 offset = 9 hours;
        uint32 newDueDate = uint32(((nowUTC + offset) / 1 days) * 1 days - offset + 30 days);
        tradeInfos[_tradeNum].dueDate = newDueDate;

        winnerPayment[_tradeNum][newWinner] = 0;
        winnerPayment[_tradeNum][prevWinner] = 0;
    }
    }


    //예치금액 출금하는함수
    function Withdraw(uint256 _amount, address _to, uint256 nonce, bytes memory signature) external 
    {
    require(verifySignatureForWithdraw(_amount, _to, nonce, signature), "Invalid signature");
    require(nonce == nonces[_to], "Invalid nonce");
    nonces[_to] += 1;
    require(userBalance[_to] >= _amount, "Insufficient balance");

    userBalance[_to] -= _amount;
    payable(_to).transfer(_amount);

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

    function viewMyDeposits(address _user) external view returns (uint256)
    {
        return userBalance[_user];
    }
}
