const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticate } = require('../middleware/auth');

// Get user profile
router.get('/:userId', userController.getUserProfile);

// Update user settings
router.put('/:userId/settings', authenticate, userController.updateSettings);

// Get user transactions
router.get('/:userId/transactions', userController.getUserTransactions);

// Update KYC tier
router.post('/:userId/kyc', authenticate, userController.updateKYC);

// Set up social recovery
router.post('/:userId/recovery', authenticate, userController.setupRecovery);

module.exports = router;