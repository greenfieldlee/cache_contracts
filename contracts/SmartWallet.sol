// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SmartWallet is Ownable {
    address public entryPoint;

    // Time-Lock Transfer Struct
    struct TimeLock {
        address recipient;
        uint256 amount;
        uint256 unlockTime;
        address tokenAddress; // Address(0) for ETH, otherwise ERC-20 token
    }

    mapping(address => TimeLock) public timeLocks; // Owner address -> TimeLock

    // Deadman’s Switch Parameters
    struct DeadTransfer {
        uint256 amount;
        address tokenAddress;
    }

    address public deadmanRecipient;
    uint256 public inactivityThreshold; // In seconds
    uint256 public lastActivityTimestamp;

    DeadTransfer[] public deadmanTransfers;

    event Execute(address indexed sender, uint256 amount);
    event ScheduledTransfer(address indexed owner, address indexed recipient, uint256 amount, uint256 unlockTime, address tokenAddress);
    event CanceledScheduledTransfer(address indexed owner, address tokenAddress);
    event ClaimedScheduledTransfer(address indexed owner, address indexed recipient, uint256 amount, address tokenAddress);
    event DeadmanTransfer(address indexed owner, address indexed recipient, uint256 amount, address tokenAddress);
    event DeadmanSwitchCanceled(address indexed owner);
    event CheckIn(address indexed owner, uint256 timestamp);

    constructor(address _entryPoint) Ownable(msg.sender) {
        entryPoint = _entryPoint;
        lastActivityTimestamp = block.timestamp; // Initialize last activity
    }

    // Explicit function for withdrawing ETH
    function _withdrawETH(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Insufficient ETH balance");
        recipient.transfer(amount);
    }

    // Explicit function for withdrawing ERC-20 tokens
    function _withdrawToken(address token, address recipient, uint256 amount) internal {
        require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient token balance");
        IERC20(token).transfer(recipient, amount);
    }

    // Generalized execution for custom calls
    function execute(address payable recipient, uint256 amount, address tokenAddress) external onlyOwner {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");

        // Route based on token address
        if (tokenAddress == address(0)) {
            _withdrawETH(recipient, amount);
        } else {
            _withdrawToken(tokenAddress, recipient, amount);
        }

        lastActivityTimestamp = block.timestamp; // Update activity timestamp
    }

    // ** Time-Lock Transfer **

    function scheduleTransfer(address recipient, uint256 amount, uint256 unlockTime, address tokenAddress) external onlyOwner {
        require(unlockTime > block.timestamp, "Unlock time must be in the future");
        require(recipient != address(0), "Invalid recipient");

        timeLocks[msg.sender] = TimeLock({
            recipient: recipient,
            amount: amount,
            unlockTime: unlockTime,
            tokenAddress: tokenAddress
        });

        emit ScheduledTransfer(msg.sender, recipient, amount, unlockTime, tokenAddress);
    }

    function claimScheduledTransfer() external {
        TimeLock memory lock = timeLocks[msg.sender];
        require(lock.recipient != address(0), "No transfer scheduled");
        require(block.timestamp >= lock.unlockTime, "Transfer is locked");

        if (lock.tokenAddress == address(0)) {
            _withdrawETH(payable(lock.recipient), lock.amount);
        } else {
            _withdrawToken(lock.tokenAddress, lock.recipient, lock.amount);
        }

        emit ClaimedScheduledTransfer(msg.sender, lock.recipient, lock.amount, lock.tokenAddress);
        delete timeLocks[msg.sender];
    }

    function cancelScheduledTransfer() external onlyOwner {
        require(timeLocks[msg.sender].recipient != address(0), "No transfer to cancel");
        address tokenAddress = timeLocks[msg.sender].tokenAddress;
        delete timeLocks[msg.sender];
        emit CanceledScheduledTransfer(msg.sender, tokenAddress);
    }

    // ** Deadman’s Switch **

    function setDeadmanRecipient(address recipient, uint256 threshold, DeadTransfer[] calldata transfers) external onlyOwner {
        require(recipient != address(0), "Invalid recipient");
        require(threshold > 0, "Threshold must be greater than zero");
        require(transfers.length > 0, "At least one transfer must be set");

        deadmanRecipient = recipient;
        inactivityThreshold = threshold;

        // Clear existing transfers
        delete deadmanTransfers;

        // Add new transfers
        for (uint256 i = 0; i < transfers.length; i++) {
            deadmanTransfers.push(transfers[i]);
        }
    }

    function getDeadmanRemainingTime() external view returns (uint256) {
        if (block.timestamp > lastActivityTimestamp + inactivityThreshold) {
            return 0;
        }
        return (lastActivityTimestamp + inactivityThreshold) - block.timestamp;
    }

    function cancelDeadmanSwitch() external onlyOwner {
        delete deadmanRecipient;
        delete deadmanTransfers;
        inactivityThreshold = 0;

        emit DeadmanSwitchCanceled(msg.sender);
    }

    function checkIn() external onlyOwner {
        lastActivityTimestamp = block.timestamp;
        emit CheckIn(msg.sender, block.timestamp);
    }

    function triggerDeadmanSwitch() external {
        require(block.timestamp > lastActivityTimestamp + inactivityThreshold, "Inactivity threshold not met");
        require(deadmanRecipient != address(0), "Deadman recipient not set");

        for (uint256 i = 0; i < deadmanTransfers.length; i++) {
            DeadTransfer memory transfer = deadmanTransfers[i];
            if (transfer.tokenAddress == address(0)) {
                _withdrawETH(payable(deadmanRecipient), transfer.amount);
            } else {
                _withdrawToken(transfer.tokenAddress, deadmanRecipient, transfer.amount);
            }
        }

        emit DeadmanTransfer(msg.sender, deadmanRecipient, address(this).balance, address(0));
    }

    // Allow receiving ETH
    receive() external payable {}

    // Fallback function for unexpected calls
    fallback() external payable {}
}
