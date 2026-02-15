class StreakCalculator {
    /**
     * Calculate current streak from submission calendar
     * @param {Object} submissionCalendar - Map of date -> submission count
     * @returns {Object} - { currentStreak, maxStreak }
     */
    calculateStreak(submissionCalendar) {
        if (!submissionCalendar || Object.keys(submissionCalendar).length === 0) {
            return { currentStreak: 0, maxStreak: 0 };
        }

        // Convert to sorted array of dates
        const dates = Object.keys(submissionCalendar)
            .filter((date) => submissionCalendar[date] > 0)
            .sort((a, b) => new Date(b) - new Date(a)); // Sort descending

        if (dates.length === 0) {
            return { currentStreak: 0, maxStreak: 0 };
        }

        let currentStreak = 0;
        let maxStreak = 0;
        let tempStreak = 0;

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Calculate current streak (from today backwards)
        let checkDate = new Date(today);
        let foundToday = false;

        for (let i = 0; i < 365; i++) {
            const dateStr = checkDate.toISOString().split('T')[0];

            if (submissionCalendar[dateStr] && submissionCalendar[dateStr] > 0) {
                if (!foundToday) {
                    foundToday = true;
                }
                currentStreak++;
            } else {
                if (foundToday) {
                    break; // Streak broken
                }
            }

            checkDate.setDate(checkDate.getDate() - 1);
        }

        // Calculate max streak
        for (let i = 0; i < dates.length; i++) {
            tempStreak = 1;

            for (let j = i + 1; j < dates.length; j++) {
                const currentDate = new Date(dates[j]);
                const prevDate = new Date(dates[j - 1]);

                const diffDays = Math.floor((prevDate - currentDate) / (1000 * 60 * 60 * 24));

                if (diffDays === 1) {
                    tempStreak++;
                } else {
                    break;
                }
            }

            maxStreak = Math.max(maxStreak, tempStreak);
        }

        return {
            currentStreak,
            maxStreak,
        };
    }

    /**
     * Generate heatmap data for last 90 days
     * @param {Object} submissionCalendar - Map of date -> submission count
     * @returns {Object} - Map of date -> count for last 90 days
     */
    generateHeatmap(submissionCalendar) {
        const heatmap = {};
        const today = new Date();

        for (let i = 0; i < 90; i++) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);
            const dateStr = date.toISOString().split('T')[0];

            heatmap[dateStr] = submissionCalendar[dateStr] || 0;
        }

        return heatmap;
    }

    /**
     * Generate weekly progress data
     * @param {Object} submissionCalendar - Map of date -> submission count
     * @returns {Array} - Array of {day, count} for last 7 days
     */
    generateWeeklyProgress(submissionCalendar) {
        const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        const weeklyData = [];
        const today = new Date();

        for (let i = 6; i >= 0; i--) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);
            const dateStr = date.toISOString().split('T')[0];
            const dayName = days[date.getDay()];

            weeklyData.push({
                day: dayName,
                count: submissionCalendar[dateStr] || 0,
            });
        }

        return weeklyData;
    }
}

module.exports = new StreakCalculator();
