import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../widgets/platform_card.dart';
import '../widgets/heatmap_widget.dart';
import '../widgets/weekly_chart.dart';
import 'profile_screen.dart';
import 'username_setup_screen.dart';
import 'leaderboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndFetchData();
  }

  Future<void> _checkAndFetchData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Check if usernames are set
    if (provider.userProfile?.leetcodeUsername == null &&
        provider.userProfile?.codeforcesUsername == null &&
        provider.userProfile?.codechefUsername == null &&
        provider.userProfile?.gfgUsername == null) {
      // Navigate to username setup
      if (mounted) {
        // Use addPostFrameCallback to avoid Navigator assertion errors
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const UsernameSetupScreen()),
            );
          }
        });
      }
    } else if (provider.dashboardData == null && provider.error == null) {
      // Fetch data if not already loaded and no previous error
      await provider.fetchDashboardData();
    }
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.refreshDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboardData == null) {
            return _buildLoadingState();
          }

          if (provider.error != null && provider.dashboardData == null) {
            return _buildErrorState(provider.error!);
          }

          final data = provider.dashboardData;
          if (data == null) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF6366F1),
            backgroundColor: const Color(0xFF1E293B),
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF0F172A),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF8B5CF6),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  // Profile Avatar
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        provider.userProfile?.name[0].toUpperCase() ?? 'U',
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          provider.userProfile?.name ?? 'User',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.local_fire_department,
                                              color: Color(0xFFF59E0B),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${data.currentStreak} Day Streak',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.9),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Leaderboard Icon
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const LeaderboardScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.leaderboard_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Profile Icon
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const ProfileScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.settings_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Solved: ${data.totalSolved} Problems',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Platform Cards Section
                        Text(
                          'Platforms',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                        
                        const SizedBox(height: 16),
                        
                        // LeetCode Card
                        PlatformCard(
                          platformName: 'LeetCode',
                          icon: Icons.code,
                          gradientColors: const [Color(0xFFFFA116), Color(0xFFFF6B00)],
                          url: provider.userProfile?.leetcodeUsername != null
                              ? 'https://leetcode.com/${provider.userProfile!.leetcodeUsername}'
                              : 'https://leetcode.com',
                          stats: {
                            'Total': data.leetcode.totalSolved.toString(),
                            'Easy': data.leetcode.easy.toString(),
                            'Medium': data.leetcode.medium.toString(),
                            'Hard': data.leetcode.hard.toString(),
                            'Rating': data.leetcode.contestRating.toString(),
                          },
                        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                        
                        const SizedBox(height: 16),
                        
                        // Codeforces Card
                        PlatformCard(
                          platformName: 'Codeforces',
                          icon: Icons.military_tech,
                          gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          url: provider.userProfile?.codeforcesUsername != null
                              ? 'https://codeforces.com/profile/${provider.userProfile!.codeforcesUsername}'
                              : 'https://codeforces.com',
                          stats: {
                            'Rating': data.codeforces.rating.toString(),
                            'Rank': data.codeforces.rank,
                          },
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                        
                        const SizedBox(height: 16),
                        
                        // CodeChef Card
                        PlatformCard(
                          platformName: 'CodeChef',
                          icon: Icons.restaurant,
                          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          url: provider.userProfile?.codechefUsername != null
                              ? 'https://www.codechef.com/users/${provider.userProfile!.codechefUsername}'
                              : 'https://www.codechef.com',
                          stats: {
                            'Rating': data.codechef.rating.toString(),
                            'Stars': '⭐' * data.codechef.stars,
                          },
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
                        
                        const SizedBox(height: 16),
                        
                        // GFG Card
                        PlatformCard(
                          platformName: 'GeeksforGeeks',
                          icon: Icons.school,
                          gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                          url: provider.userProfile?.gfgUsername != null
                              ? 'https://www.geeksforgeeks.org/user/${provider.userProfile!.gfgUsername}'
                              : 'https://www.geeksforgeeks.org',
                          stats: {
                            'Solved': data.gfg.totalSolved.toString(),
                            'Score': data.gfg.score.toString(),
                          },
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),
                        
                        const SizedBox(height: 32),
                        
                        // Analytics Section
                        Text(
                          'Analytics',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, end: 0),
                        
                        const SizedBox(height: 16),
                        
                        // Weekly Chart
                        WeeklyChart(weeklyProgress: data.weeklyProgress)
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 24),
                        
                        // Heatmap
                        HeatmapWidget(heatmapData: data.heatmapData)
                            .animate()
                            .fadeIn(delay: 700.ms)
                            .slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading your stats...',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ],
        ),
      ),
      child: Center(
        child: Text(
          'No data available',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

