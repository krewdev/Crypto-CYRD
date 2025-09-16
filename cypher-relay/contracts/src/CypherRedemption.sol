// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title CypherRedemption
 * @dev Manages the redemption of Cypher Relay Cards
 * Only authorized backend services can trigger redemptions
 */
contract CypherRedemption is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    
    bytes32 public constant REDEEMER_ROLE = keccak256("REDEEMER_ROLE");
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");
    
    IERC20 public immutable cyrdToken;
    
    // Mapping to track redeemed card hashes to prevent double-spending
    mapping(bytes32 => bool) public redeemedCards;
    
    // Events
    event CardRedeemed(
        bytes32 indexed cardHash,
        address indexed recipient,
        uint256 amount,
        uint256 timestamp
    );
    event TreasuryDeposit(address indexed from, uint256 amount);
    event TreasuryWithdrawal(address indexed to, uint256 amount);
    
    constructor(address _cyrdToken) {
        require(_cyrdToken != address(0), "Invalid token address");
        cyrdToken = IERC20(_cyrdToken);
        
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(REDEEMER_ROLE, msg.sender);
        _grantRole(TREASURY_ROLE, msg.sender);
    }
    
    /**
     * @dev Redeems a card and transfers CYRD to the recipient
     * @param cardHash The hash of the card being redeemed
     * @param recipient The address to receive the CYRD tokens
     * @param amount The amount of CYRD to transfer (with 6 decimals)
     */
    function redeemCard(
        bytes32 cardHash,
        address recipient,
        uint256 amount
    ) external onlyRole(REDEEMER_ROLE) nonReentrant whenNotPaused {
        require(cardHash != bytes32(0), "Invalid card hash");
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");
        require(!redeemedCards[cardHash], "Card already redeemed");
        
        // Mark card as redeemed
        redeemedCards[cardHash] = true;
        
        // Transfer CYRD from contract to recipient
        cyrdToken.safeTransfer(recipient, amount);
        
        emit CardRedeemed(cardHash, recipient, amount, block.timestamp);
    }
    
    /**
     * @dev Deposits CYRD tokens into the treasury
     * @param amount The amount to deposit
     */
    function depositToTreasury(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        cyrdToken.safeTransferFrom(msg.sender, address(this), amount);
        emit TreasuryDeposit(msg.sender, amount);
    }
    
    /**
     * @dev Withdraws CYRD tokens from the treasury
     * @param to The recipient address
     * @param amount The amount to withdraw
     */
    function withdrawFromTreasury(address to, uint256 amount) 
        external 
        onlyRole(TREASURY_ROLE) 
        nonReentrant 
    {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");
        cyrdToken.safeTransfer(to, amount);
        emit TreasuryWithdrawal(to, amount);
    }
    
    /**
     * @dev Returns the current treasury balance
     */
    function getTreasuryBalance() external view returns (uint256) {
        return cyrdToken.balanceOf(address(this));
    }
    
    /**
     * @dev Checks if a card has been redeemed
     */
    function isCardRedeemed(bytes32 cardHash) external view returns (bool) {
        return redeemedCards[cardHash];
    }
    
    /**
     * @dev Pauses the contract
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }
    
    /**
     * @dev Unpauses the contract
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}