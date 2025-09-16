const express = require('express');
const router = express.Router();
const cardController = require('../controllers/cardController');
const { validateRequest } = require('../middleware/validation');
const { cardValidation } = require('../validations/cardValidation');

// Redeem a card
router.post(
  '/redeem',
  validateRequest(cardValidation.redeem),
  cardController.redeemCard
);

// Check card status
router.get(
  '/status/:cardId',
  validateRequest(cardValidation.checkStatus),
  cardController.checkCardStatus
);

// Verify QR code (pre-redemption check)
router.post(
  '/verify',
  validateRequest(cardValidation.verify),
  cardController.verifyQRCode
);

module.exports = router;