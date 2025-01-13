// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../contracts/CACHE.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICacheProxy {
    function setImplementation(address newImplementation) external;

    function setBridgeWallet(address _bridgeWallet) external;

    function setExcludeFromMaxTx(address _address, bool value) external;

    function excludeFromFees(address account, bool excluded) external;

    function implementation() external view returns (address implementation_);
}

interface IBridge {
    function startBridge(
        uint256 chainId,
        address homeToken,
        uint256 amount
    ) external payable;

    function fillBridge(
        bytes32 txHash,
        uint256 chainId,
        address foreignToken,
        address toAddress,
        uint256 amount
    ) external payable;

    function getLastTrack(
        address _addr
    ) external view returns (uint256, uint256, uint256, address, uint256);
}

contract CACHE is Test {
    uint256 private _mainnetFork;

    address _ownerInternal;
    address _owner = 0x5747a7f258Bd38908A551CE6d76b8C2A428D7586;
    CACHE public cache;

    uint256 public constant BLOCK_NUMBER = 30076585;
    address public constant ZERO_ADDRESS = address(0);

    address public bridge = 0x1dcF5c55A51465B1Ab3a133F05bd956BD15264a9;
    address public cacheProxy = 0x75Ef7e9028798B4deaa10Ac8348dFE70b770325c;
    address public privateKey = 0x5c57c710bB304336B0d408DAB910870E74ad710f;

    function setUp() public {
        _mainnetFork = vm.createSelectFork(
            "base-mainnet.infura.io",
            BLOCK_NUMBER
        );

        // SwapGateway Initialization
        cache = new CACHE();

        console.log('cache', cache.address);

        // vm.prank(0x1555E20557A7c66d644202bDCFeb93C46E1b0E56);
        // ICacheProxy(cacheProxy).setImplementation(address(cache));

        // Seed balance
        vm.deal(_owner, 10 ** 18);
    }

    function testReturnUnusedTokensOwnerShip() public {
        vm.startPrank(0x5747a7f258Bd38908A551CE6d76b8C2A428D7586);

        IERC20(cacheProxy).approve(address(bridge), 10 * 10 ** 18);
        IBridge(bridge).startBridge{value: 0.007 * 10 ** 18}(
            770077,
            address(cacheProxy),
            10 * 10 ** 18
        );

        (
            uint256 curTimeStamp,
            uint256 timeStamp,
            uint256 chainId,
            address homeAddr,
            uint256 amount
        ) = IBridge(bridge).getLastTrack(
                0x5747a7f258Bd38908A551CE6d76b8C2A428D7586
            );

        console.log("curTimeStamp", curTimeStamp);
        console.log("timeStamp", timeStamp);
        console.log("chainId", chainId);
        console.log("homeAddr", homeAddr);
        console.log("amount", amount);

        vm.stopPrank();

        uint256 prevAmount = IERC20(cacheProxy).balanceOf(
            0x1555E20557A7c66d644202bDCFeb93C46E1b0E56
        );

        vm.prank(privateKey);
        IBridge(bridge).fillBridge(
            0x7b0e7820d57313cee324731d850e96b47e03e958d5ec9654f8f77cb834cae423,
            770077,
            0x75Ef7e9028798B4deaa10Ac8348dFE70b770325c,
            0x1555E20557A7c66d644202bDCFeb93C46E1b0E56,
            28111943253386654000
        );

        uint256 afterAmount = IERC20(cacheProxy).balanceOf(
            0x1555E20557A7c66d644202bDCFeb93C46E1b0E56
        );
        console.log("receive amount: ", 28111943253386654000);
        console.log("receive amount: ", afterAmount - prevAmount);
    }
}
