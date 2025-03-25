// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";




contract escrow is Ownable{
    address public OwnerAddress;//에스크로 관리자 지갑

    mapping(address => uint256) public deposits; //입금기록

    event Deposited(address indexed from, uint256 amount);// 입금 이벤트 로그 (나중에 조회하기위함)
    event Withdrawed(address indexed to, uint256 amount);// 출금 이벤트 로그 
    event Refunded(address indexed to, uint256 amount);// 환불 이벤트 로그

// 아비트럼에서는 이더리움/원화 환율을 못가져옴 -> 이더/달러 달러/원화 가져와서 이중으로 환산함
    AggregatorV3Interface internal ethUsdFeed; //이더리움 / 달러 환율
    AggregatorV3Interface internal usdKrwFeed; //달러 / 원화 환율 

    
    constructor() Ownable(msg.sender) {}

    //계좌 잔액 반환
    function getBalance() public view returns (uint256) {
        return address(this).balance;
        // 이함수는 eth 가 아니라 wei 양을 반환함 ( 1 wei = 10^-18 eth)
        // 프론트엔드에서 표시할거면 따로 바꿔야함
    }
    //컨트랙트로 입금하는 함수
    function EscrowDeposit(uint256 amount) external payable
    {
        require(msg.value == amount, "Send required ETH");
        deposits[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    //거래성사시 컨트랙트에서 판매자에게 송금하는함수(보안 중요함)
    function EscrowWithdraw(address to, uint256 amount) external payable 
    {

    }
    //거래불발시 에치금 환불해주는함수 (보안중요)  
    function EscrowRefund(address to, uint256 amount) external payable
    {

    }

}

contract ViewTransactionLog{
    
}