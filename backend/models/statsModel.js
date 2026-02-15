const mongoose = require('mongoose');

const statsSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            unique: true,
        },
        totalSolved: {
            type: Number,
            default: 0,
        },
        currentStreak: {
            type: Number,
            default: 0,
        },
        maxStreak: {
            type: Number,
            default: 0,
        },
        leetcode: {
            totalSolved: { type: Number, default: 0 },
            easy: { type: Number, default: 0 },
            medium: { type: Number, default: 0 },
            hard: { type: Number, default: 0 },
            contestRating: { type: Number, default: 0 },
            submissionCalendar: { type: Map, of: Number, default: {} },
        },
        codeforces: {
            rating: { type: Number, default: 0 },
            maxRating: { type: Number, default: 0 },
            rank: { type: String, default: 'Unrated' },
            totalSolved: { type: Number, default: 0 },
        },
        codechef: {
            rating: { type: Number, default: 0 },
            stars: { type: Number, default: 0 },
            totalSolved: { type: Number, default: 0 },
        },
        gfg: {
            totalSolved: { type: Number, default: 0 },
            score: { type: Number, default: 0 },
        },
        heatmapData: {
            type: Map,
            of: Number,
            default: {},
        },
        weeklyProgress: [
            {
                day: String,
                count: Number,
            },
        ],
        lastUpdated: {
            type: Date,
            default: Date.now,
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('Stats', statsSchema);
