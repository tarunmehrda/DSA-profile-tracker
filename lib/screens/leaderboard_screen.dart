import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import 'compare_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Leaderboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.leaderboard == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }

          final leaderboard = provider.leaderboard ?? [];

          if (leaderboard.isEmpty) {
            return Center(
              child: Text(
                'No data available',
                style: GoogleFonts.inter(color: Colors.white70),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchLeaderboard,
            color: const Color(0xFF6366F1),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final user = leaderboard[index];
                final isCurrentUser = user['userId'] == provider.userProfile?.id;

                return _buildLeaderboardItem(user, index + 1, isCurrentUser)
                    .animate()
                    .fadeIn(delay: (index * 50).ms)
                    .slideX(begin: 0.2, end: 0);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user, int rank, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? const Color(0xFF6366F1).withOpacity(0.2) 
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser 
              ? const Color(0xFF6366F1).withOpacity(0.5) 
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getRankColor(rank).withOpacity(0.2),
            border: Border.all(color: _getRankColor(rank), width: 2),
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: _getRankColor(rank),
              ),
            ),
          ),
        ),
        title: Text(
          user['name'],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.flash_on, size: 14, color: Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text(
              '${user['currentStreak']}d streak',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              user['totalSolved'].toString(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6366F1),
                fontSize: 18,
              ),
            ),
            Text(
              'Solved',
              style: GoogleFonts.inter(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
          ],
        ),
        onTap: isCurrentUser ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompareScreen(
                targetUserId: user['userId'],
                targetUserName: user['name'],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return Colors.white54;
  }
}
