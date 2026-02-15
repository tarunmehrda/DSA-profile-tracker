const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');

// Get leaderboard
router.get('/leaderboard', dashboardController.getLeaderboard.bind(dashboardController));

// Compare users
router.get('/compare', dashboardController.compareUsers.bind(dashboardController));

// Get dashboard data - using regex to ensure it only matches ObjectIds
router.get('/:userId([0-9a-fA-F]{24})', dashboardController.getDashboard.bind(dashboardController));

// Force refresh dashboard data - using regex
router.post('/:userId([0-9a-fA-F]{24})/refresh', dashboardController.refreshDashboard.bind(dashboardController));

module.exports = router;
