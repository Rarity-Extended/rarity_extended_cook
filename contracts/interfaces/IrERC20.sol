// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IrERC20 {
    function mint(uint dst, uint amount) external;
    function burn(uint dst, uint amount) external returns (bool);
    function approve(uint from, uint spender, uint amount) external returns (bool);
    function transfer(uint from, uint to, uint amount) external returns (bool);
    function transferFrom(uint executor, uint from, uint to, uint amount) external returns (bool);
}