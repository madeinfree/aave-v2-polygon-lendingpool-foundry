// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "./Constants.sol";

import "src/interfaces/ILendingPoolV2.sol";
import "src/interfaces/IAaveIncentivesController.sol";
import "src/interfaces/IERC20.sol";
import "src/interfaces/IUniswapV2Router02.sol";
import "src/interfaces/IScaledBalanceToken.sol";

contract AAVELendingPoolScript is Script {
    IERC20 private constant eth = IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
    IERC20 private constant amWETH = IERC20(0x28424507fefb6f7f8E9D3860F56504E4e5f5f390);
    IERC20 private constant variableDebtmWETH = IERC20(0xeDe17e9d79fc6f9fF9250D9EEfbdB88Cc18038b5);

    IERC20 private constant aave = IERC20(0xD6DF932A45C0f255f85145f286eA0b292B21C90B);
    IERC20 private constant aPolaave = IERC20(0xf329e36C7bF6E5E86ce2150875a84Ce77f477375);  
    ILendingPoolV2 private constant lendingPool = ILendingPoolV2(0x8dFf5E27EA6b7AC08EbFdf9eB090F32ee9a30fcf);
    IAaveIncentivesController private constant incentivesController = IAaveIncentivesController(0x357D51124f59836DeD84c8a1730D72B749d8BC23);
    IUniswapV2Router02 private constant aave2ETHRouter = IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);

    uint256 totalCollateralETH;
    uint256 totalDebtETH;
    uint256 availableBorrowsETH;
    uint256 currentLiquidationThreshold;
    uint256 ltv;
    uint256 healthFactor;

    function setUp() public {
        vm.createSelectFork(FORK_URL); 
    }

    function run() public {
        vm.startPrank(0xd814b26554204245A30F8A42C289Af582421Bf04);
        eth.approve(address(lendingPool), 10 ether);
        lendingPool.deposit(
            address(eth),
            3 ether,
            0xd814b26554204245A30F8A42C289Af582421Bf04,
            0
        );

        console.log("-----");
        console.log(unicode"清算前 User Data(清算者)");
        (totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor) = lendingPool.getUserAccountData(address(0xd814b26554204245A30F8A42C289Af582421Bf04));
        console.log(totalCollateralETH);
        console.log(totalDebtETH);
        console.log(availableBorrowsETH);
        console.log(currentLiquidationThreshold);
        console.log(ltv);
        console.log(healthFactor);
        console.log("-----");

        aave.transfer(address(0x1), 65 ether);
        vm.stopPrank();

        vm.startPrank(address(0x1));

        aave.approve(address(aave2ETHRouter), 65 ether);

        address[] memory path = new address[](2);
        path[0] = address(aave);
        path[1] = address(eth);

        aave2ETHRouter.swapExactTokensForTokens(
            60 ether,
            0,
            path,
            address(0x1),
            1659528935
        );

        console.log(unicode"Quickswap 進行 AAVE 兌換 ETH");
        console.log("------");
        console.log(unicode"獲得 ETH 數量");
        console.log(eth.balanceOf(address(0x1)));
        console.log(unicode"AAVE to ETH 交換完成!");
        console.log("------");

        eth.approve(address(lendingPool), 3 ether);

        lendingPool.deposit(
            address(eth),
            3 ether,
            address(0x1),
            0
        );

        console.log(unicode"AAVE 進行 ETH 借貸供應");
        console.log("------");
        console.log(unicode"獲得 amWETH 數量");
        uint256 beforeBalance = amWETH.balanceOf(address(0x1));
        console.log(beforeBalance);
        console.log(unicode"ETH 質押 AAVE 池完成!");
        console.log("------");

        console.log("------");
        console.log(unicode"AAVE 進行 ETH 借款");
        lendingPool.borrow(
            0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619,
            2.4 ether,
            2,
            0,
            address(0x1)
        );
        console.log(unicode"AAVE ETH 當前債務");
        uint256 beforeDebtmWETHBalance = variableDebtmWETH.balanceOf(address(0x1));
        console.log(beforeDebtmWETHBalance);
        console.log("------");

        console.log("-----");
        console.log("User Data"); 
        (totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor) = lendingPool.getUserAccountData(address(0x1));
        console.log(totalCollateralETH);
        console.log(totalDebtETH);
        console.log(availableBorrowsETH);
        console.log(currentLiquidationThreshold);
        console.log(ltv);
        console.log(healthFactor);
        console.log("-----");

        vm.warp(block.timestamp + 31536000);

        console.log("------");
        console.log(unicode"穿越時空，一年後...");
        console.log(block.timestamp + 31536000);
        console.log("------");

        console.log("------");
        console.log(unicode"AAVE ETH 0.62% 一年後債務");
        uint256 afterDebtmWETHBalance = variableDebtmWETH.balanceOf(address(0x1));
        console.log(afterDebtmWETHBalance - beforeDebtmWETHBalance);
        console.log("------");

        console.log("-----");
        console.log(unicode"Net APY 0.03% 一年後 amWETH 數量");
        uint256 afterBalance = amWETH.balanceOf(address(0x1));
        console.log(afterBalance);
        console.log("-----");

        console.log("-----");
        console.log(unicode"獲得回饋數量");
        console.log(afterBalance - beforeBalance);
        console.log("-----");

        console.log("-----");
        console.log("User Data");
        (totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor) = lendingPool.getUserAccountData(address(0x1));
        console.log(totalCollateralETH);
        console.log(totalDebtETH);
        console.log(availableBorrowsETH);
        console.log(currentLiquidationThreshold);
        console.log(ltv);
        console.log(healthFactor);
        console.log("-----");

        vm.warp(block.timestamp + 31536000 + 31536000);

        console.log("------");
        console.log(unicode"穿越時空，兩年後...");
        console.log(block.timestamp + 31536000 + 31536000);
        console.log("------");

        console.log("-----");
        console.log("User Data");
        (totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor) = lendingPool.getUserAccountData(address(0x1));
        console.log(totalCollateralETH);
        console.log(totalDebtETH);
        console.log(availableBorrowsETH);
        console.log(currentLiquidationThreshold);
        console.log(ltv);
        console.log(healthFactor);
        console.log("-----");

        vm.warp(block.timestamp + 31536000 + 31536000 + 31536000);

        console.log("------");
        console.log(unicode"穿越時空，三年後...");
        console.log(block.timestamp + 31536000 + 31536000 + 31536000);
        console.log("------");

        console.log("-----");
        console.log("User Data");
        (totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor) = lendingPool.getUserAccountData(address(0x1));
        console.log(totalCollateralETH);
        console.log(totalDebtETH);
        console.log(availableBorrowsETH);
        console.log(currentLiquidationThreshold);
        console.log(ltv);
        console.log(healthFactor);
        console.log("-----");

        vm.stopPrank();

        console.log("-----");
        console.log(unicode"清算嘗試");
        vm.prank(0xd814b26554204245A30F8A42C289Af582421Bf04); 
        lendingPool.liquidationCall(
            address(eth),
            address(eth),
            address(0x1),
            type(uint).max,
            true
        );

        console.log("-----");
        console.log(unicode"清算後結果 User Data(被清算者)");
        (totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor) = lendingPool.getUserAccountData(address(0x1));
        console.log(totalCollateralETH);
        console.log(totalDebtETH);
        console.log(availableBorrowsETH);
        console.log(currentLiquidationThreshold);
        console.log(ltv);
        console.log(healthFactor);
        console.log("-----");

        console.log("-----");
        console.log(unicode"清算後結果 User Data(清算者)");
        (totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor) = lendingPool.getUserAccountData(address(0xd814b26554204245A30F8A42C289Af582421Bf04));
        console.log(totalCollateralETH);
        console.log(totalDebtETH);
        console.log(availableBorrowsETH);
        console.log(currentLiquidationThreshold);
        console.log(ltv);
        console.log(healthFactor);
        console.log("-----");
    }
}
