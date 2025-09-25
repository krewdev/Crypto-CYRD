const express = require('express');
const router = express.Router();
const walletController = require('../controllers/walletController');
const { authenticate } = require('../middleware/auth');

// Get user wallets
router.get('/:userId', walletController.getUserWallets);

// Get wallet balances
router.post('/balances', walletController.getWalletBalances);

// Create new wallet for a chain
router.post('/create', authenticate, walletController.createWallet);

// Get wallet transaction history
router.get('/:walletId/transactions', walletController.getWalletTransactions);

module.exports = router;