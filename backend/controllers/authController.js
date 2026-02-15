const User = require('../models/userModel');
const Stats = require('../models/statsModel');
const jwt = require('jsonwebtoken');

class AuthController {
    /**
     * Register a new user
     * @route POST /api/auth/register
     */
    async register(req, res, next) {
        try {
            const { name, email, password } = req.body;

            // Validation
            if (!name || !email || !password) {
                return res.status(400).json({
                    success: false,
                    message: 'Please provide name, email, and password',
                });
            }

            // Check if user already exists
            const existingUser = await User.findOne({ email });
            if (existingUser) {
                return res.status(400).json({
                    success: false,
                    message: 'User already exists with this email',
                });
            }

            // Create user
            const user = await User.create({
                name,
                email,
                password,
            });

            // Generate token
            const token = this.generateToken(user._id);

            res.status(201).json({
                success: true,
                message: 'User registered successfully',
                data: {
                    userId: user._id,
                    name: user.name,
                    email: user.email,
                    token,
                },
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Login user
     * @route POST /api/auth/login
     */
    async login(req, res, next) {
        try {
            const { email, password } = req.body;

            // Validation
            if (!email || !password) {
                return res.status(400).json({
                    success: false,
                    message: 'Please provide email and password',
                });
            }

            // Find user and include password
            const user = await User.findOne({ email }).select('+password');
            if (!user) {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid credentials',
                });
            }

            // Check password
            const isPasswordValid = await user.comparePassword(password);
            if (!isPasswordValid) {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid credentials',
                });
            }

            // Generate token
            const token = this.generateToken(user._id);

            res.json({
                success: true,
                message: 'Login successful',
                data: {
                    userId: user._id,
                    name: user.name,
                    email: user.email,
                    token,
                },
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Update platform usernames
     * @route PUT /api/auth/usernames/:userId
     */
    async updateUsernames(req, res, next) {
        try {
            const { userId } = req.params;
            const { leetcodeUsername, codeforcesUsername, codechefUsername, gfgUsername } = req.body;

            const user = await User.findById(userId);
            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found',
                });
            }

            // Update usernames
            if (leetcodeUsername !== undefined) user.leetcodeUsername = leetcodeUsername;
            if (codeforcesUsername !== undefined) user.codeforcesUsername = codeforcesUsername;
            if (codechefUsername !== undefined) user.codechefUsername = codechefUsername;
            if (gfgUsername !== undefined) user.gfgUsername = gfgUsername;

            // Clear stats cache since usernames changed
            await Stats.findOneAndDelete({ userId });

            await user.save();

            res.json({
                success: true,
                message: 'Usernames updated successfully',
                data: {
                    leetcodeUsername: user.leetcodeUsername,
                    codeforcesUsername: user.codeforcesUsername,
                    codechefUsername: user.codechefUsername,
                    gfgUsername: user.gfgUsername,
                },
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Get user profile
     * @route GET /api/auth/profile/:userId
     */
    async getProfile(req, res, next) {
        try {
            const { userId } = req.params;

            const user = await User.findById(userId);
            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found',
                });
            }

            res.json({
                success: true,
                data: {
                    userId: user._id,
                    name: user.name,
                    email: user.email,
                    leetcodeUsername: user.leetcodeUsername,
                    codeforcesUsername: user.codeforcesUsername,
                    codechefUsername: user.codechefUsername,
                    gfgUsername: user.gfgUsername,
                },
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Generate JWT token
     */
    generateToken(userId) {
        return jwt.sign({ userId }, process.env.JWT_SECRET, {
            expiresIn: process.env.JWT_EXPIRE || '7d',
        });
    }
}

module.exports = new AuthController();
