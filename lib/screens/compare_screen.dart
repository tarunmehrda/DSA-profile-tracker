import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';

class CompareScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;

  const CompareScreen({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Map<String, dynamic>? _compareData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadComparison();
  }

  Future<void> _loadComparison() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await context.read<AppProvider>().compareWithUser(widget.targetUserId);
      setState(() {
        _compareData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Compare Profiles',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : _errorMessage != null
              ? _buildErrorState()
              : _buildComparisonView(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
          const SizedBox(height: 16),
          Text(
            'Error loading comparison',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: GoogleFonts.inter(color: Colors.white60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadComparison,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    final user1 = _compareData!['user1'];
    final user2 = _compareData!['user2'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header: User Names
          Row(
            children: [
              Expanded(child: _buildUserHeader(user1['name'], true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('VS', style: TextStyle(color: Colors.white30, fontWeight: FontWeight.bold)),
              ),
              Expanded(child: _buildUserHeader(user2['name'], false)),
            ],
          ).animate().fadeIn().scale(),

          const SizedBox(height: 32),

          // Comparison Stats
          _buildStatComparison('Total Solved', user1['totalSolved'], user2['totalSolved']),
          _buildStatComparison('Streak', user1['currentStreak'], user2['currentStreak']),
          
          const Divider(height: 48, color: Colors.white10),
          
          Text(
            'Platform Breakdown',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          _buildStatComparison('LeetCode Solved', user1['leetcode']['totalSolved'], user2['leetcode']['totalSolved']),
          _buildStatComparison('LeetCode Rating', user1['leetcode']['contestRating'], user2['leetcode']['contestRating']),
          _buildStatComparison('Codeforces Rating', user1['codeforces']['rating'], user2['codeforces']['rating']),
          _buildStatComparison('CodeChef Rating', user1['codechef']['rating'], user2['codechef']['rating']),
          _buildStatComparison('GFG Score', user1['gfg']['score'], user2['gfg']['score']),
        ],
      ),
    );
  }

  Widget _buildUserHeader(String name, bool isUser1) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isUser1 
                ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                : [const Color(0xFF10B981), const Color(0xFF059669)],
            ),
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatComparison(String label, dynamic val1, dynamic val2) {
    final num1 = val1 is num ? val1 : 0;
    final num2 = val2 is num ? val2 : 0;
    
    // Check if one value is clearly "better" (higher)
    bool val1Better = num1 > num2;
    bool val2Better = num2 > num1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildValueBar(num1.toString(), val1Better, true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildValueBar(num2.toString(), val2Better, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueBar(String value, bool isBetter, bool isLeft) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isBetter ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: isBetter ? Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)) : null,
      ),
      child: Center(
        child: Text(
          value,
          style: GoogleFonts.poppins(
            color: isBetter ? Colors.white : Colors.white70,
            fontWeight: isBetter ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
