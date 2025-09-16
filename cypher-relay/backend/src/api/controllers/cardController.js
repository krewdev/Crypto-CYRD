const { Card, User, Wallet, Transaction } = require('../../models');
const { generateWallet } = require('../../services/walletService');
const { redeemOnChain } = require('../../services/blockchainService');
const { verifyQRCodeData, hashQRCode } = require('../../utils/crypto');
const logger = require('../../utils/logger');
const { v4: uuidv4 } = require('uuid');

class CardController {
  /**
   * Redeem a card and create/fund user wallet
   */
  async redeemCard(req, res) {
    const transaction = await Card.sequelize.transaction();
    
    try {
      const { qrData, deviceId, platform } = req.body;
      
      // Verify and decode QR data
      const decodedData = verifyQRCodeData(qrData);
      if (!decodedData) {
        return res.status(400).json({
          error: 'Invalid QR code'
        });
      }
      
      // Hash the QR code for lookup
      const qrCodeHash = hashQRCode(qrData);
      
      // Find the card
      const card = await Card.findOne({
        where: { qrCodeHash },
        transaction
      });
      
      if (!card) {
        await transaction.rollback();
        return res.status(404).json({
          error: 'Card not found'
        });
      }
      
      if (card.isRedeemed) {
        await transaction.rollback();
        return res.status(400).json({
          error: 'Card already redeemed'
        });
      }
      
      // Check if card is expired
      if (card.expiresAt && new Date(card.expiresAt) < new Date()) {
        await transaction.rollback();
        return res.status(400).json({
          error: 'Card has expired'
        });
      }
      
      // Find or create user
      let user = await User.findOne({
        where: { deviceId },
        transaction
      });
      
      if (!user) {
        user = await User.create({
          deviceId,
          platform,
          appVersion: req.body.appVersion
        }, { transaction });
      }
      
      // Generate MPC wallet for the user on the card's native chain
      let wallet = await Wallet.findOne({
        where: {
          userId: user.id,
          chain: card.nativeChain
        },
        transaction
      });
      
      if (!wallet) {
        const walletData = await generateWallet(user.id, card.nativeChain);
        wallet = await Wallet.create({
          userId: user.id,
          chain: card.nativeChain,
          address: walletData.address,
          mpcKeyShare: walletData.encryptedKeyShare
        }, { transaction });
      }
      
      // Execute on-chain redemption
      const txHash = await redeemOnChain({
        chain: card.nativeChain,
        cardHash: qrCodeHash,
        recipientAddress: wallet.address,
        amount: card.tokenAmount
      });
      
      // Update card as redeemed
      await card.update({
        isRedeemed: true,
        redeemedAt: new Date(),
        redeemedByUserId: user.id,
        redeemedWalletAddress: wallet.address,
        redemptionTxHash: txHash
      }, { transaction });
      
      // Create transaction record
      await Transaction.create({
        userId: user.id,
        type: 'redemption',
        chain: card.nativeChain,
        txHash,
        status: 'pending',
        toAddress: wallet.address,
        tokenSymbol: 'CYRD',
        amount: card.tokenAmount,
        usdValue: card.value,
        description: 'Received from Cypher Card'
      }, { transaction });
      
      // Update user's total redeemed amount
      await user.increment('totalRedeemed', {
        by: parseFloat(card.value),
        transaction
      });
      
      // Update wallet balance
      await wallet.increment('balance', {
        by: parseFloat(card.tokenAmount),
        transaction
      });
      
      await transaction.commit();
      
      // Log successful redemption
      logger.info('Card redeemed successfully', {
        cardId: card.cardId,
        userId: user.id,
        chain: card.nativeChain,
        amount: card.value
      });
      
      res.json({
        success: true,
        data: {
          userId: user.id,
          walletAddress: wallet.address,
          chain: card.nativeChain,
          amount: card.value,
          tokenAmount: card.tokenAmount,
          txHash,
          message: 'Card redeemed successfully!'
        }
      });
      
    } catch (error) {
      await transaction.rollback();
      logger.error('Card redemption failed:', error);
      res.status(500).json({
        error: 'Failed to redeem card'
      });
    }
  }
  
  /**
   * Check card status without redeeming
   */
  async checkCardStatus(req, res) {
    try {
      const { cardId } = req.params;
      
      const card = await Card.findOne({
        where: { cardId },
        attributes: ['cardId', 'value', 'isRedeemed', 'expiresAt', 'nativeChain']
      });
      
      if (!card) {
        return res.status(404).json({
          error: 'Card not found'
        });
      }
      
      const isExpired = card.expiresAt && new Date(card.expiresAt) < new Date();
      
      res.json({
        data: {
          cardId: card.cardId,
          value: card.value,
          chain: card.nativeChain,
          status: card.isRedeemed ? 'redeemed' : (isExpired ? 'expired' : 'active'),
          expiresAt: card.expiresAt
        }
      });
      
    } catch (error) {
      logger.error('Card status check failed:', error);
      res.status(500).json({
        error: 'Failed to check card status'
      });
    }
  }
  
  /**
   * Verify QR code before redemption
   */
  async verifyQRCode(req, res) {
    try {
      const { qrData } = req.body;
      
      // Verify QR code format and signature
      const decodedData = verifyQRCodeData(qrData);
      if (!decodedData) {
        return res.status(400).json({
          valid: false,
          error: 'Invalid QR code format'
        });
      }
      
      // Hash and check if card exists
      const qrCodeHash = hashQRCode(qrData);
      const card = await Card.findOne({
        where: { qrCodeHash },
        attributes: ['value', 'isRedeemed', 'expiresAt', 'nativeChain']
      });
      
      if (!card) {
        return res.status(404).json({
          valid: false,
          error: 'Card not found'
        });
      }
      
      if (card.isRedeemed) {
        return res.json({
          valid: false,
          error: 'Card already redeemed'
        });
      }
      
      const isExpired = card.expiresAt && new Date(card.expiresAt) < new Date();
      if (isExpired) {
        return res.json({
          valid: false,
          error: 'Card has expired'
        });
      }
      
      res.json({
        valid: true,
        data: {
          value: card.value,
          chain: card.nativeChain
        }
      });
      
    } catch (error) {
      logger.error('QR verification failed:', error);
      res.status(500).json({
        valid: false,
        error: 'Failed to verify QR code'
      });
    }
  }
}

module.exports = new CardController();