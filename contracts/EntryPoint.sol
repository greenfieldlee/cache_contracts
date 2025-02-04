// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IWallet {
    function execute(
        address payable recipient,
        uint256 amount,
        address tokenAddress
    ) external;
}

contract EntryPoint is Ownable {
    using ECDSA for bytes32;

    event OperationExecuted(
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        address indexed tokenAddress
    );
    event BiometricRegistered(address indexed wallet, bytes32 biometricHash);
    event BundlerUpdated(
        address indexed oldBundler,
        address indexed newBundler
    );

    struct UserOperation {
        address sender;
        address payable recipient;
        uint256 amount;
        address tokenAddress;
    }

    mapping(address => mapping(bytes32 => bool)) public walletBiometrics; // Wallet -> Biometric Hashes
    address public authorizedBundler;

    constructor() payable Ownable(msg.sender) {
        authorizedBundler = msg.sender;
    }

    // Register a biometric for a wallet
    function registerBiometric(
        address wallet,
        bytes32 biometricHash
    ) external payable {
        require(
            authorizedBundler == msg.sender,
            "Only allowed bundler can register biometrics"
        );
        walletBiometrics[wallet][biometricHash] = true;
        emit BiometricRegistered(wallet, biometricHash);
    }

    // Authorize a bundler for a wallet
    function authorizeBundler(address newBundler) external payable onlyOwner {
        require(
            authorizedBundler == msg.sender,
            "Only the wallet owner can authorize bundlers"
        );
        authorizedBundler = newBundler;
        emit BundlerUpdated(authorizedBundler, newBundler);
    }

    function handleOps(
        UserOperation[] memory ops,
        bytes32 biometricHash
    ) external payable {
        require(
            authorizedBundler == msg.sender,
            "Only allowed bundler can handleOps"
        );
        for (uint256 i = 0; i < ops.length; i++) {
            UserOperation memory op = ops[i];
            require(
                _verifyBiometric(op.sender, biometricHash),
                "Invalid biometric"
            );

            try IWallet(op.sender).execute(op.recipient, op.amount, op.tokenAddress) {
                emit OperationExecuted(op.sender, op.recipient, op.amount, op.tokenAddress);
            } catch {
                revert("Operation failed for wallet");
            }

        }
    }

    function _verifyBiometric(
        address sender,
        bytes32 biometricHash
    ) internal view returns (bool) {
        return walletBiometrics[sender][biometricHash];
    }
}
