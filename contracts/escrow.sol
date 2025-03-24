// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

contract escrow{
    address public OwnerAddress;//에스크로 관리자 지갑

    mapping(address => uint256) public deposits; //입금기록

    event Deposited(address indexed from, uint256 amount);// 입금 이벤트 로그 (나중에 조회하기위함)
    event Withdrawed(address indexed to, uint256 amount);// 출금 이벤트 로그 
    event Refunded(address indexed to, uint256 amount);// 환불 이벤트 로그
    constructor() 
    {
        OwnerAddress = msg.sender; // 내 지갑주소
    }



    //관리자 지갑으로 입금하는 함수
    function EscrowDeposit(uint256 amount) external payable
    {
        require(msg.value == amount, "Send required ETH");
        deposits[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    //거래성사시 관리자 지갑에서 판매자에게 송금하는함수(보안 중요함)
    function EscrowWithdraw(address to, uint256 amount) external payable 
    {

    }
    //거래불발시 에치금 환불해주는함수 (보안중요)  2414
    function EscrowRefund(address to, uint256 amount) external payable
    {

    }

}

contract ViewTransactionLog{
    
}