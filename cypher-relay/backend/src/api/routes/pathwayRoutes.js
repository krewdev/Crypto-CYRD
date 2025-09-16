const express = require('express');
const router = express.Router();
const pathwayController = require('../controllers/pathwayController');

// Get all pathways
router.get('/', pathwayController.getAllPathways);

// Get user's pathway progress
router.get('/progress/:userId', pathwayController.getUserProgress);

// Update pathway progress
router.put('/progress/:userId', pathwayController.updateProgress);

// Complete a pathway lesson
router.post('/lesson/complete', pathwayController.completeLesson);

// Submit quiz answer
router.post('/quiz/submit', pathwayController.submitQuizAnswer);

module.exports = router;