import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeatmapWidget extends StatelessWidget {
  final Map<String, int> heatmapData;

  const HeatmapWidget({
    super.key,
    required this.heatmapData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: const Color(0xFF6366F1),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Activity Heatmap',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Heatmap Grid
          _buildHeatmapGrid(),
          
          const SizedBox(height: 16),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Less',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _getColorForIntensity(index / 4),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                'More',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    // Get last 84 days (12 weeks)
    final now = DateTime.now();
    final days = <DateTime>[];
    
    for (int i = 83; i >= 0; i--) {
      days.add(now.subtract(Duration(days: i)));
    }

    // Group by weeks
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, (i + 7).clamp(0, days.length)));
    }

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weeks.map((week) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: week.map((day) {
              final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
              final count = heatmapData[dateStr] ?? 0;
              final maxCount = heatmapData.values.isEmpty ? 1 : heatmapData.values.reduce((a, b) => a > b ? a : b);
              final intensity = maxCount > 0 ? count / maxCount : 0.0;
              
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _getColorForIntensity(intensity),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForIntensity(double intensity) {
    if (intensity == 0) {
      return Colors.white.withOpacity(0.1);
    } else if (intensity < 0.25) {
      return const Color(0xFF6366F1).withOpacity(0.3);
    } else if (intensity < 0.5) {
      return const Color(0xFF6366F1).withOpacity(0.5);
    } else if (intensity < 0.75) {
      return const Color(0xFF6366F1).withOpacity(0.7);
    } else {
      return const Color(0xFF6366F1);
    }
  }
}
