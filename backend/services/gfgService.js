const puppeteer = require('puppeteer');

class GFGService {
    constructor() {
        this.baseUrl = 'https://www.geeksforgeeks.org';
    }

    async getUserStats(username) {
        try {
            console.log(`Fetching GFG stats for user: ${username}`);
            
            let browser;
            try {
                // Use Puppeteer for reliable data extraction
                browser = await puppeteer.launch({
                    headless: true,
                    args: ['--no-sandbox', '--disable-setuid-sandbox']
                });
                
                const page = await browser.newPage();
                await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
                
                const profileUrl = `${this.baseUrl}/user/${username}`;
                console.log(`Loading: ${profileUrl}`);
                
                await page.goto(profileUrl, {
                    waitUntil: 'networkidle2',
                    timeout: 30000
                });
                
                // Wait for dynamic content to load
                await new Promise(resolve => setTimeout(resolve, 3000));
                
                const stats = await page.evaluate(() => {
                    let score = 0;
                    let totalSolved = 0;
                    
                    // Method 1: Try to extract from script data (fastest if available)
                    const scripts = document.querySelectorAll('script');
                    
                    for (const script of scripts) {
                        const content = script.textContent;
                        if (content && content.includes('total_problems_solved')) {
                            const scoreMatch = content.match(/"score":\s*(\d+)/);
                            const solvedMatch = content.match(/"total_problems_solved":\s*(\d+)/);
                            
                            if (scoreMatch) score = parseInt(scoreMatch[1]);
                            if (solvedMatch) totalSolved = parseInt(solvedMatch[1]);
                            
                            if (score > 0 && totalSolved > 0) break; // Found both values
                        }
                    }
                    
                    // Method 2: Extract from visible elements (most reliable for current GFG)
                    if (score === 0 || totalSolved === 0) {
                        // Look for the main container that holds both stats
                        const infoContainers = document.querySelectorAll('.Activity_info-container__fuKQO');
                        
                        infoContainers.forEach(container => {
                            const text = container.textContent?.trim();
                            if (!text) return;
                            
                            // Extract score and totalSolved from the container text
                            const scoreMatch = text.match(/Coding Score(\d+)/);
                            const solvedMatch = text.match(/Problems Solved(\d+)/);
                            
                            if (scoreMatch) score = parseInt(scoreMatch[1]);
                            if (solvedMatch) totalSolved = parseInt(solvedMatch[1]);
                        });
                        
                        // Fallback: Look for individual score cards
                        if (score === 0 || totalSolved === 0) {
                            const scoreCards = document.querySelectorAll('.ScoreContainer_score-card__zI4vG');
                            
                            scoreCards.forEach(card => {
                                const text = card.textContent?.trim();
                                if (!text) return;
                                
                                if (text.includes('Problems Solved')) {
                                    const match = text.match(/(\d+)/);
                                    if (match) totalSolved = parseInt(match[1]);
                                }
                                
                                if (text.includes('Coding Score')) {
                                    const match = text.match(/(\d+)/);
                                    if (match) score = parseInt(match[1]);
                                }
                            });
                        }
                    }
                    
                    return { totalSolved, score };
                });
                
                return stats;
                
            } finally {
                if (browser) {
                    await browser.close();
                }
            }
            
        } catch (error) {
            console.error('GFG Scraping Error:', error.message);

            if (error.message.includes('404') || error.message.includes('not found')) {
                throw new Error('GeeksforGeeks user not found');
            }

            // If scraping fails, return zeros instead of failing
            console.warn('GFG scraping failed, returning default values');
            return {
                totalSolved: 0,
                score: 0,
            };
        }
    }
}

module.exports = new GFGService();
