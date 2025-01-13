// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../contracts/Bridge.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IIncomeIslandCoin {
    function burnToken(address _user, uint256 _amount) external;
}

contract BridgeTest is Test {
    uint256 private _mainnetFork;

    address _ownerInternal;
    address _owner = 0x1cAEe2D3Ae572c56bBF454a6077Ec66Be4Ce4cF3;
    Bridge public bridge;

    uint256 public constant BLOCK_NUMBER = 28635760;
    address public constant ZERO_ADDRESS = address(0);

    address public incomeIslandCoin =
        0x75Ef7e9028798B4deaa10Ac8348dFE70b770325c;

    function setUp() public {
        _mainnetFork = vm.createSelectFork(
            "https://bsc-dataseed2.binance.org/",
            BLOCK_NUMBER
        );

        // SwapGateway Initialization
        bridge = new Bridge();

        vm.prank(0x1555E20557A7c66d644202bDCFeb93C46E1b0E56);
        IIncomeIslandCoin(incomeIslandCoin).burnToken(_owner, 1000 * 10 ** 18);

        // Seed balance
        vm.deal(_owner, 10 ** 18);
    }

    function testReturnUnusedTokensOwnerShip() public {
        vm.startPrank(_owner);
        IERC20(incomeIslandCoin).transfer(address(bridge), 10 * 10 ** 18);

        bridge.returnUnusedTokens();
        vm.stopPrank();
    }

    function testStartBridge() public {
        vm.startPrank(_owner);

        IERC20(incomeIslandCoin).approve(address(bridge), 100 * 10 ** 18);

        console.log("============= StartBridge =============");

        bridge.startBridge{value: 0.007 * 10 ** 18}(
            770077,
            incomeIslandCoin,
            100 * 10 ** 18
        );

        console.log(
            "balance: birdge contract: ",
            IERC20(incomeIslandCoin).balanceOf(address(bridge))
        );

        (uint256 x1, , , , ) = bridge.getLastTrack(_owner);

        console.log("getLastTrack", x1);

        console.log("============= fillBridge =============");

        bridge.fillBridge(
            0xd248b14de2f701af7a86152739823414429b380df048ad1ca3335fc01098be64,
            87,
            incomeIslandCoin,
            0x5747a7f258Bd38908A551CE6d76b8C2A428D7586,
            90 * 10 ** 18
        );

        console.log(
            "balance: birdge contract: ",
            IERC20(incomeIslandCoin).balanceOf(address(bridge))
        );

        vm.stopPrank();
    }
}
