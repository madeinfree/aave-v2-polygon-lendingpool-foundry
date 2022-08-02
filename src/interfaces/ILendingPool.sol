// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ILendingPool {
  function deposit(address _reserve, uint256 _amount, address onBehalfOf, uint16 _referralCode) external;
  function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
}