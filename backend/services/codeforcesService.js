const axios = require('axios');

class CodeforcesService {
    constructor() {
        this.baseUrl = 'https://codeforces.com/api';
    }

    async getUserStats(username) {
        try {
            // Fetch user info
            const userInfoResponse = await axios.get(`${this.baseUrl}/user.info`, {
                params: { handles: username },
            });

            if (userInfoResponse.data.status !== 'OK') {
                throw new Error('Codeforces user not found');
            }

            const userInfo = userInfoResponse.data.result[0];

            // Fetch user submissions
            const submissionsResponse = await axios.get(`${this.baseUrl}/user.status`, {
                params: { handle: username },
            });

            let totalSolved = 0;
            const solvedProblems = new Set();

            if (submissionsResponse.data.status === 'OK') {
                submissionsResponse.data.result.forEach((submission) => {
                    if (submission.verdict === 'OK') {
                        const problemId = `${submission.problem.contestId}-${submission.problem.index}`;
                        solvedProblems.add(problemId);
                    }
                });
                totalSolved = solvedProblems.size;
            }

            return {
                rating: userInfo.rating || 0,
                maxRating: userInfo.maxRating || 0,
                rank: userInfo.rank || 'Unrated',
                totalSolved,
            };
        } catch (error) {
            console.error('Codeforces API Error:', error.message);

            if (error.response?.data?.comment) {
                throw new Error(`Codeforces: ${error.response.data.comment}`);
            }

            throw new Error(`Failed to fetch Codeforces data: ${error.message}`);
        }
    }

    getRankName(rating) {
        if (rating < 1200) return 'Newbie';
        if (rating < 1400) return 'Pupil';
        if (rating < 1600) return 'Specialist';
        if (rating < 1900) return 'Expert';
        if (rating < 2100) return 'Candidate Master';
        if (rating < 2300) return 'Master';
        if (rating < 2400) return 'International Master';
        if (rating < 2600) return 'Grandmaster';
        if (rating < 3000) return 'International Grandmaster';
        return 'Legendary Grandmaster';
    }
}

module.exports = new CodeforcesService();
