// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
 * Pre Sale Contract
 */
contract Presale is Ownable {
    using SafeERC20 for IERC20;

    address public saleToken;
    address public marketingWallet;
    uint256 public tokensPerUnit;

    mapping(address => uint256) public userContribution;

    event ContributionProcessed(address indexed contributor, uint256 amount, uint256 tokensSent);
    event SaleTokenUpdated(address indexed oldToken, address indexed newToken);
    event MarketingWalletUpdated(address indexed oldWallet, address indexed newWallet);
    event TokensPerUnitUpdated(uint256 oldRate, uint256 newRate);
    event FundsCollected(uint256 amount);
    event UnusedTokensReturned(uint256 amount);
    event RemoveWrongTokens(address indexed token);

    constructor(address _saleToken, address _marketingWallet, uint256 _tokensPerUnit) Ownable(msg.sender) payable {
        require(_saleToken != address(0), "Presale: Invalid saleToken addr");
        require(_marketingWallet != address(0), "Presale: Invalid marketing addr");
        require(_tokensPerUnit != 0, "Presale: tokensPerUnit err");

        saleToken = _saleToken;
        marketingWallet = _marketingWallet;
        tokensPerUnit = _tokensPerUnit;
    }

    receive() external payable {
        _processContribution(msg.sender, msg.value);
        payable(marketingWallet).transfer(address(this).balance);
    }

    /*
     * Admin Functions
     */
    function returnUnusedTokens() external payable onlyOwner {
        uint256 tokenBalance = IERC20(saleToken).balanceOf(address(this));
        require(tokenBalance != 0, "Presale: No unused tokens to return");
        IERC20(saleToken).safeTransfer(msg.sender, tokenBalance);
        emit UnusedTokensReturned(tokenBalance);
    }

    function collectSaleFunds() external payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance != 0, "Presale: No funds to collect");
        payable(marketingWallet).transfer(balance);
        emit FundsCollected(balance);
    }

    function removeWrongTokens(address token_) external payable onlyOwner {
        require(token_ != saleToken, "Presale: Cannot remove sale token");
        uint256 tokenBalance = IERC20(token_).balanceOf(address(this));
        require(tokenBalance != 0, "Presale: No tokens to remove");
        IERC20(token_).safeTransfer(msg.sender, tokenBalance);
        emit RemoveWrongTokens(token_);
    }

    function updateSaleToken(address _saleToken) external payable onlyOwner {
        require(_saleToken != address(0), "Presale: Invalid sale token address");
        require(_saleToken != saleToken, "Presale: No need to update");
        emit SaleTokenUpdated(saleToken, _saleToken);
        saleToken = _saleToken;
    }

    function updateMarketingWallet(address _marketingWallet) external payable onlyOwner {
        require(_marketingWallet != address(0), "Presale: Invalid marketing wallet address");
        require(_marketingWallet != marketingWallet, "Presale: No need to update");
        emit MarketingWalletUpdated(marketingWallet, _marketingWallet);
        marketingWallet = _marketingWallet;
    }

    function updateTokensPerUnit(uint256 _tokensPerUnit) external payable onlyOwner {
        require(_tokensPerUnit != 0, "Presale: tokensPerUnit err");
        require(_tokensPerUnit != tokensPerUnit, "Presale: No need to update");
        emit TokensPerUnitUpdated(tokensPerUnit, _tokensPerUnit);
        tokensPerUnit = _tokensPerUnit;
    }

    /*
     * Basic Contract Functions
     */
    function _processContribution(address wallet_, uint256 amount_) internal {
        require(amount_ != 0, "Presale: amount err");
        uint256 tokensToSend = amount_ * tokensPerUnit;
        uint256 tokenBalance = IERC20(saleToken).balanceOf(address(this));
        require(tokensToSend < tokenBalance + 1, "Presale: Not enough tokens remain");

        IERC20(saleToken).safeTransfer(wallet_, tokensToSend);
        userContribution[wallet_] += amount_;
        emit ContributionProcessed(wallet_, amount_, tokensToSend);
    }
}
