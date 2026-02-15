const axios = require('axios');
const cheerio = require('cheerio');

class CodeChefService {
    constructor() {
        this.baseUrl = 'https://www.codechef.com';
    }

    async getUserStats(username) {
        try {
            const profileUrl = `${this.baseUrl}/users/${username}`;

            const response = await axios.get(profileUrl, {
                headers: {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                },
            });

            const $ = cheerio.load(response.data);

            // Extract rating
            const ratingText = $('.rating-number').first().text().trim();
            const rating = parseInt(ratingText) || 0;

            // Extract stars
            const starsText = $('.rating-star').find('span').text().trim();
            const stars = starsText.split('★').length - 1 || 0;

            // Extract problems solved
            const problemsSolvedText = $('.problems-solved h3').text().trim();
            const totalSolved = parseInt(problemsSolvedText) || 0;

            return {
                rating,
                stars,
                totalSolved,
            };
        } catch (error) {
            console.error('CodeChef Scraping Error:', error.message);

            // Return default values if scraping fails
            if (error.response?.status === 404) {
                throw new Error('CodeChef user not found');
            }

            // If scraping structure changed, return zeros instead of failing
            console.warn('CodeChef scraping may need update, returning default values');
            return {
                rating: 0,
                stars: 0,
                totalSolved: 0,
            };
        }
    }
}

module.exports = new CodeChefService();
