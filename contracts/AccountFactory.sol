// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./SmartWallet.sol";

contract AccountFactory {
    address public entryPoint;

    event AccountCreated(address indexed account, address indexed owner);

    constructor(address _entryPoint) {
        entryPoint = _entryPoint;
    }

    function createAccount() external returns (address) {
        SmartWallet account = new SmartWallet(entryPoint);
        account.transferOwnership(entryPoint);
        emit AccountCreated(address(account), entryPoint);
        return address(account);
    }
}
