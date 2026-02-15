import 'platform_stats.dart';

class DashboardData {
  final int totalSolved;
  final int currentStreak;
  final LeetCodeStats leetcode;
  final CodeforcesStats codeforces;
  final CodeChefStats codechef;
  final GFGStats gfg;
  final Map<String, int> heatmapData; // date -> count
  final List<DailyProgress> weeklyProgress;

  DashboardData({
    required this.totalSolved,
    required this.currentStreak,
    required this.leetcode,
    required this.codeforces,
    required this.codechef,
    required this.gfg,
    required this.heatmapData,
    required this.weeklyProgress,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalSolved: json['totalSolved'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      leetcode: LeetCodeStats.fromJson(json['leetcode'] ?? {}),
      codeforces: CodeforcesStats.fromJson(json['codeforces'] ?? {}),
      codechef: CodeChefStats.fromJson(json['codechef'] ?? {}),
      gfg: GFGStats.fromJson(json['gfg'] ?? {}),
      heatmapData: Map<String, int>.from(json['heatmapData'] ?? {}),
      weeklyProgress: (json['weeklyProgress'] as List?)
              ?.map((e) => DailyProgress.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory DashboardData.empty() {
    return DashboardData(
      totalSolved: 0,
      currentStreak: 0,
      leetcode: LeetCodeStats(
        totalSolved: 0,
        easy: 0,
        medium: 0,
        hard: 0,
        contestRating: 0,
      ),
      codeforces: CodeforcesStats(rating: 0, rank: 'Unrated'),
      codechef: CodeChefStats(rating: 0, stars: 0),
      gfg: GFGStats(totalSolved: 0, score: 0),
      heatmapData: {},
      weeklyProgress: [],
    );
  }
}

class DailyProgress {
  final String day;
  final int count;

  DailyProgress({
    required this.day,
    required this.count,
  });

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      day: json['day'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
