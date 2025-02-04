// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/***
 *
 *                                                    ,--,
 *      ,----..      ,---,          ,----..         ,--.'|     ,---,.
 *     /   /   \    '  .' \        /   /   \     ,--,  | :   ,'  .' |
 *    |   :     :  /  ;    '.     |   :     : ,---.'|  : ' ,---.'   |
 *    .   |  ;. / :  :       \    .   |  ;. / |   | : _' | |   |   .'
 *    .   ; /--`  :  |   /\   \   .   ; /--`  :   : |.'  | :   :  |-,
 *    ;   | ;     |  :  ' ;.   :  ;   | ;     |   ' '  ; : :   |  ;/|
 *    |   : |     |  |  ;/  \   \ |   : |     '   |  .'. | |   :   .'
 *    .   | '___  '  :  | \  \ ,' .   | '___  |   | :  | ' |   |  |-,
 *    '   ; : .'| |  |  '  '--'   '   ; : .'| '   : |  : ; '   :  ;/|
 *    '   | '/  : |  :  :         '   | '/  : |   | '  ,/  |   |    \
 *    |   :    /  |  | ,'         |   :    /  ;   : ;--'   |   :   .'
 *     \   \ .'   `--''            \   \ .'   |   ,/       |   | ,'
 *      `---`                       `---`     '---'        `----'
 *
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./ERC20.sol";

contract CACHE is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public maxSellTransactionAmount;
    uint256 public maxHoldLimitPercent;

    struct AddressConfig {
        bool isAutomatedMarketMakerPair;
        bool isExcludedFromMaxTx;
        bool isExcludedFromMaxHold;
    }

    mapping(address user => AddressConfig config) public addressConfigs;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ExcludedFromMaxTx(address indexed account, bool isExcluded);
    event ExcludedFromMaxHold(address indexed account, bool isExcluded);
    event MaxHoldLimitUpdated(uint256 newLimitPercent);
    event MaxSellTransactionAmountUpdated(uint256 amount);
    event TransferInitiated(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event WithdrawTokens(address indexed tokenAddress, uint256 amount);
    event WithdrawETH(address indexed recipient, uint256 amount);

    constructor(address adminAddr) ERC20("CACHE", "CACHE") Ownable(adminAddr) {
        uint256 initialSupply = 1_000_000_000 * 10 ** 18; // 1 billion tokens with 18 decimals
        _mint(adminAddr, initialSupply);

        maxSellTransactionAmount = 5_000_000 * 10 ** 18; // 5 million tokens with 18 decimals
        maxHoldLimitPercent = 3; // Default max hold limit is 3%

        // Directly update storage without copying to memory
        addressConfigs[adminAddr].isExcludedFromMaxTx = true;
        addressConfigs[adminAddr].isExcludedFromMaxHold = true;
    }

    function setMaxSellTransactionAmount(uint256 amount) external onlyOwner {
        require(
            maxSellTransactionAmount != amount,
            "CACHE: No need to update."
        );
        require(
            maxSellTransactionAmount > 3_000_000 * 10 ** 18,
            "CACHE: Limit err."
        );
        maxSellTransactionAmount = amount;
        emit MaxSellTransactionAmountUpdated(amount);
    }

    function setMaxHoldLimitPercent(uint256 percent) external onlyOwner {
        require(maxHoldLimitPercent != percent, "CACHE: No need to update.");
        require(percent > 2, "CACHE: Min hold limit error");
        require(percent < 101, "CACHE: Max hold limit error");
        maxHoldLimitPercent = percent;
        emit MaxHoldLimitUpdated(percent);
    }

    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        require(pair != address(0), "CACHE: Invalid pair address");
        require(
            addressConfigs[pair].isAutomatedMarketMakerPair != value,
            "CACHE: No need to update."
        );

        // Directly update the specific field in storage
        addressConfigs[pair].isAutomatedMarketMakerPair = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromMaxTx(
        address account,
        bool excluded
    ) external onlyOwner {
        require(
            addressConfigs[account].isExcludedFromMaxTx != excluded,
            "CACHE: No need to update."
        );

        // Directly update the specific field in storage
        addressConfigs[account].isExcludedFromMaxTx = excluded;

        emit ExcludedFromMaxTx(account, excluded);
    }

    function excludeFromMaxHold(
        address account,
        bool excluded
    ) external onlyOwner {
        require(
            addressConfigs[account].isExcludedFromMaxHold != excluded,
            "CACHE: No need to update."
        );

        // Directly update the specific field in storage
        addressConfigs[account].isExcludedFromMaxHold = excluded;

        emit ExcludedFromMaxHold(account, excluded);
    }

    function withdrawTokens(
        address tokenAddress,
        uint256 amount
    ) external onlyOwner nonReentrant {
        require(tokenAddress != address(0), "CACHE: Invalid token address");
        IERC20(tokenAddress).safeTransfer(msg.sender, amount);
        emit WithdrawTokens(tokenAddress, amount);
    }

    function _beforeTokenTransferCheck(
        address from,
        address to,
        uint256 amount
    ) internal view {
        require(from != address(0), "ERC20: transfer from zero addr");
        require(to != address(0), "ERC20: transfer to zero addr");

        // Cache storage variables to reduce SLOAD operations
        AddressConfig memory senderConfig = addressConfigs[from];
        AddressConfig memory receiverConfig = addressConfigs[to];

        // Check max transaction limits if applicable
        if (
            !senderConfig.isExcludedFromMaxTx &&
            !receiverConfig.isExcludedFromMaxTx
        ) {
            if (receiverConfig.isAutomatedMarketMakerPair) {
                require(
                    amount <= maxSellTransactionAmount,
                    "CACHE: Sell amount exceeds"
                );
            }
        }

        // Check max hold limits if applicable
        if (
            !receiverConfig.isExcludedFromMaxHold &&
            !receiverConfig.isAutomatedMarketMakerPair
        ) {
            uint256 maxHoldAmount = (totalSupply() * maxHoldLimitPercent) / 100;
            require(
                balanceOf(to) + amount <= maxHoldAmount,
                "CACHE: Hold amount exceeds"
            );
        }
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        _beforeTokenTransferCheck(msg.sender, to, amount);

        bool success = super.transfer(to, amount);
        emit TransferInitiated(msg.sender, to, amount);
        return success;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _beforeTokenTransferCheck(from, to, amount);

        bool success = super.transferFrom(from, to, amount);
        emit TransferInitiated(from, to, amount);
        return success;
    }

    /**
     * @dev Withdraw ETH to owner
     */
    /**
     * @dev Withdraws all ETH from the contract to the owner
     */
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        // ✅ Use `call` instead of `.transfer()` for gas flexibility
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "ETH withdrawal failed");

        emit WithdrawETH(owner(), balance);
    }
}
