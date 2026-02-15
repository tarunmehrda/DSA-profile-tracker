const User = require('../models/userModel');
const Stats = require('../models/statsModel');
const leetcodeService = require('../services/leetcodeService');
const codeforcesService = require('../services/codeforcesService');
const codechefService = require('../services/codechefService');
const gfgService = require('../services/gfgService');
const streakCalculator = require('../utils/streakCalculator');

class DashboardController {
    /**
     * Get dashboard data for a user
     * @route GET /api/dashboard/:userId
     */
    async getDashboard(req, res, next) {
        try {
            const { userId } = req.params;

            // Find user
            const user = await User.findById(userId);
            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found',
                });
            }

            // Check if stats exist and are recent (within cache duration)
            let stats = await Stats.findOne({ userId });
            const cacheDuration = parseInt(process.env.CACHE_DURATION) || 3600000; // 1 hour
            const now = Date.now();

            if (stats && now - stats.lastUpdated.getTime() < cacheDuration) {
                // Return cached data
                return res.json({
                    success: true,
                    data: this.formatStatsResponse(stats),
                    cached: true,
                });
            }

            // Fetch fresh data from all platforms
            const platformData = await this.fetchAllPlatformData(user);

            // Calculate totals and streak
            const totalSolved =
                platformData.leetcode.totalSolved +
                platformData.codeforces.totalSolved +
                platformData.codechef.totalSolved +
                platformData.gfg.totalSolved;

            const streakData = streakCalculator.calculateStreak(
                platformData.leetcode.submissionCalendar
            );

            const heatmapData = streakCalculator.generateHeatmap(
                platformData.leetcode.submissionCalendar
            );

            const weeklyProgress = streakCalculator.generateWeeklyProgress(
                platformData.leetcode.submissionCalendar
            );

            // Update or create stats
            if (stats) {
                stats.totalSolved = totalSolved;
                stats.currentStreak = streakData.currentStreak;
                stats.maxStreak = streakData.maxStreak;
                stats.leetcode = platformData.leetcode;
                stats.codeforces = platformData.codeforces;
                stats.codechef = platformData.codechef;
                stats.gfg = platformData.gfg;
                stats.heatmapData = heatmapData;
                stats.weeklyProgress = weeklyProgress;
                stats.lastUpdated = new Date();
                await stats.save();
            } else {
                stats = await Stats.create({
                    userId,
                    totalSolved,
                    currentStreak: streakData.currentStreak,
                    maxStreak: streakData.maxStreak,
                    leetcode: platformData.leetcode,
                    codeforces: platformData.codeforces,
                    codechef: platformData.codechef,
                    gfg: platformData.gfg,
                    heatmapData,
                    weeklyProgress,
                });

                user.stats = stats._id;
                await user.save();
            }

            res.json({
                success: true,
                data: this.formatStatsResponse(stats),
                cached: false,
            });
        } catch (error) {
            console.error('DASHBOARD ERROR:', error);
            next(error);
        }
    }

    /**
     * Fetch data from all platforms
     */
    async fetchAllPlatformData(user) {
        const results = {
            leetcode: { totalSolved: 0, easy: 0, medium: 0, hard: 0, contestRating: 0, submissionCalendar: {} },
            codeforces: { rating: 0, maxRating: 0, rank: 'Unrated', totalSolved: 0 },
            codechef: { rating: 0, stars: 0, totalSolved: 0 },
            gfg: { totalSolved: 0, score: 0 },
        };

        console.log(`Starting parallel fetch for user: ${user.name}`);

        const fetchPromises = [];

        // LeetCode
        if (user.leetcodeUsername) {
            fetchPromises.push(
                leetcodeService.getUserStats(user.leetcodeUsername)
                    .then(data => {
                        results.leetcode = data;
                        console.log('- LeetCode OK');
                    })
                    .catch(err => console.error(`LeetCode failed: ${err.message}`))
            );
        }

        // Codeforces
        if (user.codeforcesUsername) {
            fetchPromises.push(
                codeforcesService.getUserStats(user.codeforcesUsername)
                    .then(data => {
                        results.codeforces = data;
                        console.log('- Codeforces OK');
                    })
                    .catch(err => console.error(`Codeforces failed: ${err.message}`))
            );
        }

        // CodeChef
        if (user.codechefUsername) {
            fetchPromises.push(
                codechefService.getUserStats(user.codechefUsername)
                    .then(data => {
                        results.codechef = data;
                        console.log('- CodeChef OK');
                    })
                    .catch(err => console.error(`CodeChef failed: ${err.message}`))
            );
        }

        // GFG
        if (user.gfgUsername) {
            fetchPromises.push(
                gfgService.getUserStats(user.gfgUsername)
                    .then(data => {
                        results.gfg = data;
                        console.log('- GFG OK');
                    })
                    .catch(err => console.error(`GFG failed: ${err.message}`))
            );
        }

        await Promise.all(fetchPromises);
        console.log('All platform fetches completed');

        return results;
    }

    /**
     * Format stats response
     */
    formatStatsResponse(stats) {
        return {
            totalSolved: stats.totalSolved,
            currentStreak: stats.currentStreak,
            leetcode: {
                totalSolved: stats.leetcode.totalSolved,
                easy: stats.leetcode.easy,
                medium: stats.leetcode.medium,
                hard: stats.leetcode.hard,
                contestRating: stats.leetcode.contestRating,
            },
            codeforces: {
                rating: stats.codeforces.rating,
                rank: stats.codeforces.rank,
            },
            codechef: {
                rating: stats.codechef.rating,
                stars: stats.codechef.stars,
            },
            gfg: {
                totalSolved: stats.gfg.totalSolved,
                score: stats.gfg.score,
            },
            heatmapData: stats.heatmapData ? Object.fromEntries(stats.heatmapData) : {},
            weeklyProgress: stats.weeklyProgress,
        };
    }

    /**
     * Force refresh dashboard data
     * @route POST /api/dashboard/:userId/refresh
     */
    async refreshDashboard(req, res, next) {
        try {
            const { userId } = req.params;

            // Delete existing stats to force refresh
            await Stats.findOneAndDelete({ userId });

            // Call getDashboard to fetch fresh data
            req.params.userId = userId;
            await this.getDashboard(req, res, next);
        } catch (error) {
            console.error('DASHBOARD ERROR:', error);
            next(error);
        }
    }

    async getLeaderboard(req, res, next) {
        try {
            // Get all users
            const users = await User.find().select('name stats').populate('stats');

            const data = users.map((user) => {
                const stat = user.stats;
                return {
                    userId: user._id,
                    name: user.name || 'Unknown',
                    totalSolved: stat ? stat.totalSolved : 0,
                    currentStreak: stat ? stat.currentStreak : 0,
                    leetcodeSolved: stat ? stat.leetcode.totalSolved : 0,
                    codeforcesRating: stat ? stat.codeforces.rating : 0,
                    codechefStars: stat ? stat.codechef.stars : 0,
                    gfgScore: stat ? stat.gfg.score : 0,
                };
            });

            // Sort by total solved
            data.sort((a, b) => b.totalSolved - a.totalSolved);

            res.json({
                success: true,
                data: data.slice(0, 50), // Limit to top 50
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Compare two users
     * @route GET /api/dashboard/compare
     */
    async compareUsers(req, res, next) {
        try {
            const { user1Id, user2Id } = req.query;

            if (!user1Id || !user2Id) {
                return res.status(400).json({
                    success: false,
                    message: 'Please provide both user1Id and user2Id',
                });
            }

            const [user1, user2] = await Promise.all([
                User.findById(user1Id).populate('stats'),
                User.findById(user2Id).populate('stats'),
            ]);

            if (!user1 || !user2) {
                return res.status(404).json({
                    success: false,
                    message: 'One or both users not found',
                });
            }

            const formatUserStats = (user) => {
                if (user.stats) {
                    return {
                        name: user.name,
                        ...this.formatStatsResponse(user.stats),
                    };
                }
                // Return default empty stats if no stats exist yet
                return {
                    name: user.name,
                    totalSolved: 0,
                    currentStreak: 0,
                    leetcode: { totalSolved: 0, easy: 0, medium: 0, hard: 0, contestRating: 0 },
                    codeforces: { rating: 0, rank: 'Unrated' },
                    codechef: { rating: 0, stars: 0 },
                    gfg: { totalSolved: 0, score: 0 },
                    heatmapData: {},
                    weeklyProgress: [],
                };
            };

            res.json({
                success: true,
                data: {
                    user1: formatUserStats(user1),
                    user2: formatUserStats(user2),
                },
            });
        } catch (error) {
            next(error);
        }
    }
}

module.exports = new DashboardController();
