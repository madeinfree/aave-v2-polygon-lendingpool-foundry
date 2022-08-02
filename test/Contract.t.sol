// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/interfaces/ILendingPool.sol";
import "src/interfaces/IERC20.sol";

contract AAVEDeposier is Test {
    IERC20 private constant aave = IERC20(0xD6DF932A45C0f255f85145f286eA0b292B21C90B);
    ILendingPool private constant lendingPool = ILendingPool(0x794a61358D6845594F94dc1DB02A252b5b4814aD);

    function setUp() public {}

    function testExample() public {
        assertTrue(true);
    }
}
