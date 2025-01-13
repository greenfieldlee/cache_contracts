// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

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
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address);
}

contract CACHE is ERC20, Ownable {
    uint256 public maxSellTransactionAmount;
    uint256 public maxHoldLimitPercent;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private _isExcludedFromMaxTx;
    mapping(address => bool) private _isExcludeFromMaxHold;
    IUniswapV2Router02 public uniswapV2Router;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ExcludedFromMaxTx(address indexed account, bool isExcluded);
    event ExcludedFromMaxHold(address indexed account, bool isExcluded);
    event MaxHoldLimitUpdated(uint256 newLimitPercent);

    constructor(address routerAddress) ERC20("CACHE Coin", "CACHE") {
        address ownerAddress = msg.sender;
        uint256 initialSupply = 1000000000 * (10 ** 18); // 1 billion tokens with 18 decimals
        _mint(ownerAddress, initialSupply);
        _isExcludedFromMaxTx[ownerAddress] = true;
        _isExcludeFromMaxHold[ownerAddress] = true;
        maxSellTransactionAmount = 10000000 * (10 ** 18);
        maxHoldLimitPercent = 10; // Default max hold limit is 10%

        uniswapV2Router = IUniswapV2Router02(routerAddress);
        address pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
        if (pair != address(0)) {
            setAutomatedMarketMakerPair(pair, true);
        }
    }

    function setMaxSellTransactionAmount(uint256 amount) external onlyOwner {
        maxSellTransactionAmount = amount;
    }

    function setMaxHoldLimitPercent(uint256 percent) external onlyOwner {
        require(percent > 0 && percent <= 100, "CACHE: Invalid max hold limit");
        maxHoldLimitPercent = percent;
        emit MaxHoldLimitUpdated(percent);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != address(0), "CACHE: Invalid pair address");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromMaxTx(address account, bool excluded) external onlyOwner {
        _isExcludedFromMaxTx[account] = excluded;
        emit ExcludedFromMaxTx(account, excluded);
    }

    function excludeFromMaxHold(address account, bool excluded) external onlyOwner {
        _isExcludeFromMaxHold[account] = excluded;
        emit ExcludedFromMaxHold(account, excluded);
    }

    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        require(tokenAddress != address(0), "CACHE: Invalid token address");
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (!_isExcludedFromMaxTx[from] && !_isExcludedFromMaxTx[to]) {
            if (automatedMarketMakerPairs[to]) {
                require(amount <= maxSellTransactionAmount, "CACHE: Sell amount exceeds the maxSellTransactionAmount");
            }
        }

        if (!_isExcludeFromMaxHold[to]) {
            uint256 maxHoldAmount = (totalSupply() * maxHoldLimitPercent) / 100;
            require(balanceOf(to) + amount <= maxHoldAmount, "CACHE: Transfer exceeds max hold limit");
        }

        super._transfer(from, to, amount);
    }
}
