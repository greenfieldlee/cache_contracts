// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../contracts/MiningCenter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IProxy {
    function setLOGIC(address newLogicAddress) external;

    function manageStakingType(
        uint256 _stakedays,
        uint256 _stakeratedays,
        uint256 _index,
        uint16 _mode
    ) external;

    function getExpectedInStakingReward(
        address _owner,
        uint256 _nftNum,
        uint256 _nftType,
        uint256 _note
    ) external view returns (uint256, uint256, uint256);
}

contract Mining is Test {
    uint256 private _mainnetFork;

    address _ownerInternal;
    address _owner = 0x1cAEe2D3Ae572c56bBF454a6077Ec66Be4Ce4cF3;
    address miningProxy = 0xb51D7Ac845D2A427199D7d0c145ac230F4799d21;

    MiningCenter public _miningCenter;

    uint256 public constant BLOCK_NUMBER = 30299466;
    address public constant ZERO_ADDRESS = address(0);

    function setUp() public {
        _mainnetFork = vm.createSelectFork(
            "https://bsc-dataseed2.binance.org",
            BLOCK_NUMBER
        );

        // SwapGateway Initialization
        _miningCenter = new MiningCenter();

        console.log("_miningCenter", address(_miningCenter));

        // vm.prank(0x1555E20557A7c66d644202bDCFeb93C46E1b0E56);
        // IProxy(miningProxy).setLOGIC(address(_miningCenter));

        // vm.prank(0x1555E20557A7c66d644202bDCFeb93C46E1b0E56);
        // IProxy(miningProxy).manageStakingType(90, 4800, 3, 0);

        // vm.prank(0x1555E20557A7c66d644202bDCFeb93C46E1b0E56);
        // IProxy(miningProxy).manageStakingType(180, 4320, 2, 0);

        // vm.prank(0x1555E20557A7c66d644202bDCFeb93C46E1b0E56);
        // IProxy(miningProxy).manageStakingType(270, 2400, 4, 0);

        // Seed balance
        vm.deal(_owner, 10 ** 18);
    }

    function testReturnUnusedTokensOwnerShip() public {
        // vm.startPrank(0x5747a7f258Bd38908A551CE6d76b8C2A428D7586);
        // (
        //     uint256 _earnedUSDT,
        //     uint256 _ownerIncomeAmount,
        //     uint256 _marketingIncomeAmount
        // ) = IProxy(miningProxy).getExpectedInStakingReward(
        //         0x5747a7f258Bd38908A551CE6d76b8C2A428D7586,
        //         35,
        //         2,
        //         1
        //     );
        // console.log("_earnedUSDT", _earnedUSDT);
        // console.log("_ownerIncomeAmount", _ownerIncomeAmount);
        // console.log("_marketingIncomeAmount", _marketingIncomeAmount);
        // vm.stopPrank();
    }
}
