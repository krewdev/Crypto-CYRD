const { ethers } = require('ethers');
const logger = require('../utils/logger');

// Import contract ABIs
const CypherRelayDollarABI = require('../../contracts/abi/CypherRelayDollar.json');
const CypherRedemptionABI = require('../../contracts/abi/CypherRedemption.json');

class BlockchainService {
  constructor() {
    this.providers = {};
    this.signers = {};
    this.contracts = {};
    
    this.initializeProviders();
    this.initializeContracts();
  }
  
  /**
   * Initialize blockchain providers
   */
  initializeProviders() {
    // Polygon
    this.providers.polygon = new ethers.JsonRpcProvider(
      process.env.POLYGON_RPC_URL || 'https://polygon-rpc.com'
    );
    
    // Arbitrum
    this.providers.arbitrum = new ethers.JsonRpcProvider(
      process.env.ARBITRUM_RPC_URL || 'https://arb1.arbitrum.io/rpc'
    );
    
    // Initialize signers with backend private key
    if (process.env.BACKEND_PRIVATE_KEY) {
      this.signers.polygon = new ethers.Wallet(
        process.env.BACKEND_PRIVATE_KEY,
        this.providers.polygon
      );
      this.signers.arbitrum = new ethers.Wallet(
        process.env.BACKEND_PRIVATE_KEY,
        this.providers.arbitrum
      );
    }
  }
  
  /**
   * Initialize smart contract instances
   */
  initializeContracts() {
    // Polygon contracts
    if (process.env.REDEMPTION_CONTRACT_POLYGON) {
      this.contracts.polygon = {
        redemption: new ethers.Contract(
          process.env.REDEMPTION_CONTRACT_POLYGON,
          CypherRedemptionABI,
          this.signers.polygon || this.providers.polygon
        ),
        token: new ethers.Contract(
          process.env.CYRD_TOKEN_POLYGON,
          CypherRelayDollarABI,
          this.providers.polygon
        )
      };
    }
    
    // Arbitrum contracts
    if (process.env.REDEMPTION_CONTRACT_ARBITRUM) {
      this.contracts.arbitrum = {
        redemption: new ethers.Contract(
          process.env.REDEMPTION_CONTRACT_ARBITRUM,
          CypherRedemptionABI,
          this.signers.arbitrum || this.providers.arbitrum
        ),
        token: new ethers.Contract(
          process.env.CYRD_TOKEN_ARBITRUM,
          CypherRelayDollarABI,
          this.providers.arbitrum
        )
      };
    }
  }
  
  /**
   * Execute on-chain redemption
   */
  async redeemOnChain({ chain, cardHash, recipientAddress, amount }) {
    try {
      const contracts = this.contracts[chain];
      if (!contracts) {
        throw new Error(`Chain ${chain} not configured`);
      }
      
      // Convert amount to proper decimals (CYRD uses 6 decimals)
      const amountWithDecimals = ethers.parseUnits(amount.toString(), 6);
      
      // Check if card already redeemed on-chain
      const isRedeemed = await contracts.redemption.isCardRedeemed(cardHash);
      if (isRedeemed) {
        throw new Error('Card already redeemed on blockchain');
      }
      
      // Execute redemption transaction
      logger.info('Executing on-chain redemption', {
        chain,
        cardHash,
        recipient: recipientAddress,
        amount: amount.toString()
      });
      
      const tx = await contracts.redemption.redeemCard(
        cardHash,
        recipientAddress,
        amountWithDecimals
      );
      
      // Wait for confirmation
      const receipt = await tx.wait();
      
      logger.info('Redemption transaction confirmed', {
        chain,
        txHash: receipt.hash,
        blockNumber: receipt.blockNumber
      });
      
      return receipt.hash;
      
    } catch (error) {
      logger.error('On-chain redemption failed:', error);
      throw error;
    }
  }
  
  /**
   * Get CYRD balance for an address
   */
  async getCYRDBalance(address, chain) {
    try {
      const contracts = this.contracts[chain];
      if (!contracts) {
        throw new Error(`Chain ${chain} not configured`);
      }
      
      const balance = await contracts.token.balanceOf(address);
      const formattedBalance = ethers.formatUnits(balance, 6);
      
      return {
        raw: balance.toString(),
        formatted: formattedBalance,
        usd: formattedBalance // Since CYRD is 1:1 with USD
      };
      
    } catch (error) {
      logger.error('Failed to get CYRD balance:', error);
      throw error;
    }
  }
  
  /**
   * Send CYRD tokens
   */
  async sendCYRD({ fromPrivateKey, toAddress, amount, chain }) {
    try {
      const provider = this.providers[chain];
      if (!provider) {
        throw new Error(`Chain ${chain} not configured`);
      }
      
      // Create wallet from private key
      const wallet = new ethers.Wallet(fromPrivateKey, provider);
      
      // Get token contract with signer
      const tokenContract = new ethers.Contract(
        this.contracts[chain].token.address,
        CypherRelayDollarABI,
        wallet
      );
      
      // Convert amount to proper decimals
      const amountWithDecimals = ethers.parseUnits(amount.toString(), 6);
      
      // Execute transfer
      const tx = await tokenContract.transfer(toAddress, amountWithDecimals);
      const receipt = await tx.wait();
      
      logger.info('CYRD transfer completed', {
        chain,
        from: wallet.address,
        to: toAddress,
        amount: amount.toString(),
        txHash: receipt.hash
      });
      
      return {
        txHash: receipt.hash,
        blockNumber: receipt.blockNumber,
        gasUsed: receipt.gasUsed.toString()
      };
      
    } catch (error) {
      logger.error('CYRD transfer failed:', error);
      throw error;
    }
  }
  
  /**
   * Estimate gas for a transaction
   */
  async estimateGas(chain, transaction) {
    try {
      const provider = this.providers[chain];
      const gasEstimate = await provider.estimateGas(transaction);
      const gasPrice = await provider.getFeeData();
      
      const estimatedCost = gasEstimate * gasPrice.gasPrice;
      
      return {
        gasLimit: gasEstimate.toString(),
        gasPrice: gasPrice.gasPrice.toString(),
        maxFeePerGas: gasPrice.maxFeePerGas?.toString(),
        maxPriorityFeePerGas: gasPrice.maxPriorityFeePerGas?.toString(),
        estimatedCost: ethers.formatEther(estimatedCost)
      };
      
    } catch (error) {
      logger.error('Gas estimation failed:', error);
      throw error;
    }
  }
  
  /**
   * Monitor transaction status
   */
  async getTransactionStatus(txHash, chain) {
    try {
      const provider = this.providers[chain];
      const tx = await provider.getTransaction(txHash);
      
      if (!tx) {
        return { status: 'not_found' };
      }
      
      const receipt = await provider.getTransactionReceipt(txHash);
      
      if (!receipt) {
        return { status: 'pending', transaction: tx };
      }
      
      return {
        status: receipt.status === 1 ? 'confirmed' : 'failed',
        transaction: tx,
        receipt: receipt,
        confirmations: await tx.confirmations()
      };
      
    } catch (error) {
      logger.error('Failed to get transaction status:', error);
      throw error;
    }
  }
}

module.exports = new BlockchainService();