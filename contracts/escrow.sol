// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";




contract escrow is Ownable{

    mapping(address => mapping(uint64 => uint256)) public bidsMap;  //입찰자 / 거래번호 / 금액 매핑
    mapping(address => uint256) public deposits; //입금자 / 금액 매핑
    uint256 proceeds = 0; //경매 낙찰로 컨트랙트에 귀속되는 금액
    enum ActionType { DEPOSIT, WITHDRAW, REFUND }
    
    
    // 경매 이벤트 로그 (나중에 조회하기위함)
    event BidEvents(address indexed from, uint256 amount, uint256 timestamp, ActionType action);

    //입출금 이벤트 로그
    event Transactions(address indexed participant, uint256 amount, uint256 timestamp, ActionType action); 


    // 아비트럼에서는 이더리움/원화 환율을 못가져옴 -> 이더/달러 달러/원화 가져와서 이중으로 환산함
    AggregatorV3Interface internal ethUsdFeed; //이더리움 / 달러 환율
    AggregatorV3Interface internal usdKrwFeed; //달러 / 원화 환율 


    constructor() Ownable(msg.sender) {}

    //계좌 잔액 반환
    function getBalance() public view returns (uint256) 
    {
        return address(this).balance;
        // 이함수는 eth 가 아니라 wei 양을 반환함 ( 1 wei = 10^-18 eth)
        // 프론트엔드에서 표시할거면 따로 바꿔야함
    }


    //컨트랙트로 입금하는 함수
    // amount = 입금할 금액 from = 보내는 사람 주소 (로그인 데이터에서 가져올것)
    function EscrowDeposit(uint256 amount, address from) external payable 
    {
        //계좌에 이더가 충분하지 않을시
        require(msg.value == amount, "Send required ETH");
        //로그인 데이터에 적힌 주소와 실제 주소가 다를시
        require(msg.sender == from, "Check your account"); 
        deposits[msg.sender] += msg.value;
        emit Transactions(msg.sender, msg.value, block.timestamp, ActionType.DEPOSIT);
    }


    //경매 입찰 함수
    function Bid(uint64 tradeNum, uint256 amount, address from) external
    {

    }


    //거래성사시 에치금 환불해주는함수
    function EscrowRefund(uint256 amount, uint64 tradeNum) external payable
    {

    }

    //예치금액 출금하는함수
    function Withdraw(uint256 amount, address to) external
    {

    }

    //경매 운영자가 저장된 금액 회수하는함수
    function Collectproceeds(uint256 amount) external onlyOwner
    {
        require(proceeds >= amount, "Not enough balance");
        payable(owner()).transfer(amount);
    }
}

contract ViewTransactionLog{
    
}