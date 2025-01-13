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

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address);
}

contract CACHE is ERC20, Ownable2Step {
    using SafeERC20 for IERC20;

    uint256 public maxSellTransactionAmount;
    uint256 public maxHoldLimitPercent;

    struct AddressConfig {
        bool isAutomatedMarketMakerPair;
        bool isExcludedFromMaxTx;
        bool isExcludedFromMaxHold;
    }

    mapping(address => AddressConfig) private _addressConfigs;
    IUniswapV2Router02 public uniswapV2Router;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ExcludedFromMaxTx(address indexed account, bool isExcluded);
    event ExcludedFromMaxHold(address indexed account, bool isExcluded);
    event MaxHoldLimitUpdated(uint256 newLimitPercent);
    event MaxSellTransactionAmountUpdated(uint256 amount);
    event TransferInitiated(address from, address to, uint256 amount);
    event WithdrawTokens(address tokenAddress, uint256 amount);

    constructor(address routerAddress) payable ERC20("CACHE Coin", "CACHE") {
        address ownerAddress = msg.sender;
        uint256 initialSupply = 10 ** 27; // 1 billion tokens with 18 decimals
        _mint(ownerAddress, initialSupply);
        maxSellTransactionAmount = 5 * 10 ** 24;
        maxHoldLimitPercent = 5; // Default max hold limit is 5%

        _addressConfigs[ownerAddress].isExcludedFromMaxTx = true;
        _addressConfigs[ownerAddress].isExcludedFromMaxHold = true;

        uniswapV2Router = IUniswapV2Router02(routerAddress);
        address pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
        if (pair != address(0)) {
            setAutomatedMarketMakerPair(pair, true);
        }
    }

    function setMaxSellTransactionAmount(uint256 amount) external payable onlyOwner {
        require(maxSellTransactionAmount != amount, "CACHE: No need to update.");
        maxSellTransactionAmount = amount;
        emit MaxSellTransactionAmountUpdated(amount);
    }

    function setMaxHoldLimitPercent(uint256 percent) external payable onlyOwner {
        require(maxHoldLimitPercent != percent, "CACHE: No need to update.");
        require(percent != 0, "CACHE: Max hold limit error");
        require(percent < 101, "CACHE: Max hold limit error");
        maxHoldLimitPercent = percent;
        emit MaxHoldLimitUpdated(percent);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != address(0), "CACHE: Invalid pair address");
        require(_addressConfigs[pair].isAutomatedMarketMakerPair != value, "CACHE: No need to update.");
        _addressConfigs[pair].isAutomatedMarketMakerPair = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromMaxTx(address account, bool excluded) external payable onlyOwner {
        require(_addressConfigs[account].isExcludedFromMaxTx != excluded, "CACHE: No need to update.");
        _addressConfigs[account].isExcludedFromMaxTx = excluded;
        emit ExcludedFromMaxTx(account, excluded);
    }

    function excludeFromMaxHold(address account, bool excluded) external payable onlyOwner {
        require(_addressConfigs[account].isExcludedFromMaxHold != excluded, "CACHE: No need to update.");
        _addressConfigs[account].isExcludedFromMaxHold = excluded;
        emit ExcludedFromMaxHold(account, excluded);
    }

    function withdrawTokens(address tokenAddress, uint256 amount) external payable onlyOwner {
        require(tokenAddress != address(0), "CACHE: Invalid token address");
        IERC20(tokenAddress).safeTransfer(msg.sender, amount);
        emit WithdrawTokens(tokenAddress, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from zero addr");
        require(to != address(0), "ERC20: transfer to zero addr");

        bool excludedFromMaxTxFrom = _addressConfigs[from].isExcludedFromMaxTx;
        bool excludedFromMaxTxTo = _addressConfigs[to].isExcludedFromMaxTx;
        if (!excludedFromMaxTxFrom && !excludedFromMaxTxTo) {
            if (_addressConfigs[to].isAutomatedMarketMakerPair) {
                require(amount < maxSellTransactionAmount, "CACHE: Sell amount exceeds");
            }
        }

        if (!_addressConfigs[to].isExcludedFromMaxHold) {
            uint256 maxHoldAmount = totalSupply() / 10; // Cache max hold limit value to avoid repeated calculation
            require(balanceOf(to) + amount < maxHoldAmount, "CACHE: Hold amount exceeds");
        }

        super._transfer(from, to, amount);
        emit TransferInitiated(from, to, amount);
    }
}
