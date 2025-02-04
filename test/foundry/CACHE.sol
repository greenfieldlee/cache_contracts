// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/CACHE.sol"; // Adjust this import based on your contract location

contract CACHETest is Test {
    CACHE public cacheContract;
    address public owner = address(0x5747a7f258Bd38908A551CE6d76b8C2A428D7586); // Test contract deployer (Owner)
    address public attacker = address(0x1cAEe2D3Ae572c56bBF454a6077Ec66Be4Ce4cF3); // Fake attacker address
    address public routerAddr = address(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24); // Fake attacker address

    function setUp() public {
        vm.createSelectFork("https://mainnet.base.org");
        // ✅ Deploy the contract
        cacheContract = new CACHE(routerAddr, owner);

        // ✅ Send ETH to the contract (Simulating deposits)
        vm.deal(address(cacheContract), 1 ether);
    }

    function testWithdrawETHAsOwner() public {
        // ✅ Check initial contract balance
        uint256 initialBalance = address(cacheContract).balance;
        assertEq(initialBalance, 1 ether, "Contract should have 1 ETH");

        // ✅ Owner withdraws ETH
        uint256 ownerBalanceBefore = address(owner).balance;
        vm.prank(owner);
        cacheContract.withdrawETH();
        uint256 ownerBalanceAfter = address(owner).balance;

        // ✅ Ensure owner received the ETH
        assertEq(address(cacheContract).balance, 0, "Contract balance should be 0 after withdrawal");
        assertGt(ownerBalanceAfter, ownerBalanceBefore, "Owner should receive ETH");
    }

    function testCannotWithdrawWhenEmpty() public {
        vm.prank(owner);
        // ✅ Withdraw first (empty the contract)
        cacheContract.withdrawETH();

        // ✅ Attempting to withdraw again should fail
        vm.prank(owner);
        vm.expectRevert("No funds to withdraw");
        cacheContract.withdrawETH();
    }

    function testAttackWithdraw() public {
        vm.prank(attacker);
        // ✅ Withdraw first (empty the contract)
        cacheContract.withdrawETH();

        assertEq(address(cacheContract).balance, 0, "Contract balance should be 0 after withdrawal");
    }
}
