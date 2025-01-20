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
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address);
}

contract CACHE is ERC20, Ownable2Step, ReentrancyGuard  {
    using SafeERC20 for IERC20;

    uint256 public maxSellTransactionAmount;
    uint256 public maxHoldLimitPercent;

    struct AddressConfig {
        bool isAutomatedMarketMakerPair;
        bool isExcludedFromMaxTx;
        bool isExcludedFromMaxHold;
    }

    mapping(address user => AddressConfig config) public addressConfigs;
    IUniswapV2Router02 public uniswapV2Router;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ExcludedFromMaxTx(address indexed account, bool isExcluded);
    event ExcludedFromMaxHold(address indexed account, bool isExcluded);
    event MaxHoldLimitUpdated(uint256 newLimitPercent);
    event MaxSellTransactionAmountUpdated(uint256 amount);
    event TransferInitiated(address indexed from, address indexed to, uint256 amount);
    event WithdrawTokens(address indexed tokenAddress, uint256 amount);

    constructor(address routerAddress) payable ERC20("CACHE", "CACHE") {
        address ownerAddress = msg.sender;
        uint256 initialSupply = 1_000_000_000 * 10 ** 18; // 1 billion tokens with 18 decimals
        _mint(ownerAddress, initialSupply);
        
        maxSellTransactionAmount = 5_000_000 * 10 ** 18; // 5 million tokens with 18 decimals
        maxHoldLimitPercent = 3; // Default max hold limit is 5%

        // Cache addressConfigs[ownerAddress] in memory
        AddressConfig memory ownerConfig = addressConfigs[ownerAddress];
        ownerConfig.isExcludedFromMaxTx = true;
        ownerConfig.isExcludedFromMaxHold = true;
        addressConfigs[ownerAddress] = ownerConfig; // Write back to storage once

        // Set up Uniswap router and pair
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
        uniswapV2Router = router; // Store in storage once

        address pair = IUniswapV2Factory(router.factory()).getPair(address(this), router.WETH());
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
        
        // Cache the storage variable in memory
        AddressConfig memory config = addressConfigs[pair];
        
        require(config.isAutomatedMarketMakerPair != value, "CACHE: No need to update.");
        
        // Update the cached variable
        config.isAutomatedMarketMakerPair = value;
        
        // Write the updated config back to storage
        addressConfigs[pair] = config;
        
        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function excludeFromMaxTx(address account, bool excluded) external payable onlyOwner {
        // Cache the storage variable in memory
        AddressConfig memory config = addressConfigs[account];
        
        require(config.isExcludedFromMaxTx != excluded, "CACHE: No need to update.");
        
        // Update the cached variable
        config.isExcludedFromMaxTx = excluded;
        
        // Write the updated config back to storage
        addressConfigs[account] = config;
        
        emit ExcludedFromMaxTx(account, excluded);
    }

    function excludeFromMaxHold(address account, bool excluded) external payable onlyOwner {
        // Cache the storage variable in memory
        AddressConfig memory config = addressConfigs[account];
        
        require(config.isExcludedFromMaxHold != excluded, "CACHE: No need to update.");
        
        // Update the cached variable
        config.isExcludedFromMaxHold = excluded;
        
        // Write the updated config back to storage
        addressConfigs[account] = config;
        
        emit ExcludedFromMaxHold(account, excluded);
    }


    function withdrawTokens(address tokenAddress, uint256 amount) external payable onlyOwner nonReentrant {
        require(tokenAddress != address(0), "CACHE: Invalid token address");
        IERC20(tokenAddress).safeTransfer(msg.sender, amount);
        emit WithdrawTokens(tokenAddress, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from zero addr");
        require(to != address(0), "ERC20: transfer to zero addr");

        // Cache storage variables to reduce SLOAD operations
        AddressConfig memory fromConfig = addressConfigs[from];
        AddressConfig memory toConfig = addressConfigs[to];

        // Check max transaction limits if applicable
        if (!fromConfig.isExcludedFromMaxTx && !toConfig.isExcludedFromMaxTx) {
            if (toConfig.isAutomatedMarketMakerPair) {
                require(amount <= maxSellTransactionAmount, "CACHE: Sell amount exceeds");
            }
        }

        // Check max hold limits if applicable
        if (!toConfig.isExcludedFromMaxHold) {
            uint256 maxHoldAmount = (totalSupply() * maxHoldLimitPercent) / 100;
            require(balanceOf(to) + amount <= maxHoldAmount, "CACHE: Hold amount exceeds");
        }

        super._transfer(from, to, amount);
        emit TransferInitiated(from, to, amount);
    }
}
