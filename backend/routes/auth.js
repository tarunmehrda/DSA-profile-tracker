const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Register new user
router.post('/register', authController.register.bind(authController));

// Login user
router.post('/login', authController.login.bind(authController));

// Get user profile
router.get('/profile/:userId', authController.getProfile.bind(authController));

// Update platform usernames
router.put('/usernames/:userId', authController.updateUsernames.bind(authController));

module.exports = router;
