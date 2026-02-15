import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import 'dashboard_screen.dart';

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final _leetcodeController = TextEditingController();
  final _codeforcesController = TextEditingController();
  final _codechefController = TextEditingController();
  final _gfgController = TextEditingController();

  @override
  void dispose() {
    _leetcodeController.dispose();
    _codeforcesController.dispose();
    _codechefController.dispose();
    _gfgController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // At least one username must be provided
    if (_leetcodeController.text.isEmpty &&
        _codeforcesController.text.isEmpty &&
        _codechefController.text.isEmpty &&
        _gfgController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter at least one username',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.updateUsernames(
      leetcodeUsername: _leetcodeController.text.isEmpty ? null : _leetcodeController.text,
      codeforcesUsername: _codeforcesController.text.isEmpty ? null : _codeforcesController.text,
      codechefUsername: _codechefController.text.isEmpty ? null : _codechefController.text,
      gfgUsername: _gfgController.text.isEmpty ? null : _gfgController.text,
    );

    if (mounted) {
      // Use addPostFrameCallback to avoid Navigator assertion errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Setup Your Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                
                const SizedBox(height: 8),
                
                Text(
                  'Enter your usernames for different coding platforms',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ).animate().fadeIn(delay: 100.ms),
                
                const SizedBox(height: 40),
                
                // LeetCode
                _buildUsernameField(
                  controller: _leetcodeController,
                  label: 'LeetCode Username',
                  icon: Icons.code,
                  color: const Color(0xFFFFA116),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                
                const SizedBox(height: 20),
                
                // Codeforces
                _buildUsernameField(
                  controller: _codeforcesController,
                  label: 'Codeforces Username',
                  icon: Icons.military_tech,
                  color: const Color(0xFF3B82F6),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
                
                const SizedBox(height: 20),
                
                // CodeChef
                _buildUsernameField(
                  controller: _codechefController,
                  label: 'CodeChef Username',
                  icon: Icons.restaurant,
                  color: const Color(0xFF8B5CF6),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),
                
                const SizedBox(height: 20),
                
                // GFG
                _buildUsernameField(
                  controller: _gfgController,
                  label: 'GeeksforGeeks Username',
                  icon: Icons.school,
                  color: const Color(0xFF10B981),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, end: 0),
                
                const SizedBox(height: 40),
                
                // Save Button
                Consumer<AppProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save & Continue',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            icon,
            color: color,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
