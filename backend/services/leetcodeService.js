const axios = require('axios');

class LeetCodeService {
    constructor() {
        this.graphqlEndpoint = 'https://leetcode.com/graphql';
    }

    async getUserStats(username) {
        try {
            const query = `
        query getUserProfile($username: String!) {
          matchedUser(username: $username) {
            username
            submitStats {
              acSubmissionNum {
                difficulty
                count
              }
            }
            profile {
              ranking
              reputation
            }
          }
          userContestRanking(username: $username) {
            rating
          }
          recentSubmissionList(username: $username) {
            timestamp
            statusDisplay
          }
        }
      `;

            const response = await axios.post(
                this.graphqlEndpoint,
                {
                    query,
                    variables: { username },
                },
                {
                    headers: {
                        'Content-Type': 'application/json',
                        'Referer': 'https://leetcode.com',
                    },
                }
            );

            const data = response.data.data;

            if (!data.matchedUser) {
                throw new Error('LeetCode user not found');
            }

            const submissions = data.matchedUser.submitStats.acSubmissionNum;
            const easy = submissions.find((s) => s.difficulty === 'Easy')?.count || 0;
            const medium = submissions.find((s) => s.difficulty === 'Medium')?.count || 0;
            const hard = submissions.find((s) => s.difficulty === 'Hard')?.count || 0;
            const totalSolved = submissions.find((s) => s.difficulty === 'All')?.count || 0;

            const contestRating = Math.round(data.userContestRanking?.rating || 0);

            // Build submission calendar
            const submissionCalendar = {};
            if (data.recentSubmissionList) {
                data.recentSubmissionList.forEach((sub) => {
                    if (sub.statusDisplay === 'Accepted') {
                        const date = new Date(parseInt(sub.timestamp) * 1000)
                            .toISOString()
                            .split('T')[0];
                        submissionCalendar[date] = (submissionCalendar[date] || 0) + 1;
                    }
                });
            }

            return {
                totalSolved,
                easy,
                medium,
                hard,
                contestRating,
                submissionCalendar,
            };
        } catch (error) {
            console.error('LeetCode API Error:', error.message);
            throw new Error(`Failed to fetch LeetCode data: ${error.message}`);
        }
    }
}

module.exports = new LeetCodeService();
