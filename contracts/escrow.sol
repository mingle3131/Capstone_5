// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

contract escrow{
    address public OwnerAddress;//에스크로 관리자 지갑
    event Deposited(address indexed from, uint256 amount);// 입금 이벤트 로그 (나중에 조회하기위함)
    event Withdrawed(address indexed to, uint256 amount);// 출금 이벤트 로그 
    event Refunded(address indexed to, uint256 amount);// 환불 이벤트 로그 (나중에 조회하기위함)
    constructor() 
    {
        OwnerAddress = msg.sender; // 내 지갑주소
    }

    //관리자 지갑으로 입금하는 함수
    function EscrowDeposit() external payable
    {
        require(msg.value > 0, "Send some ETH");
        //입금 로직 들어갈곳
        emit Deposited(msg.sender, msg.value);
    }
    //관리자 지갑에서 환불하거나 판매자에게 송금하는함수(보안 중요함)
    function EscrowWithdraw() external payable 
    {

    }
    function EscrowRefund() external payable
    {

    }

}