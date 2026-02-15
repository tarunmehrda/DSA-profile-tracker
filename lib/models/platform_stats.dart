class LeetCodeStats {
  final int totalSolved;
  final int easy;
  final int medium;
  final int hard;
  final int contestRating;

  LeetCodeStats({
    required this.totalSolved,
    required this.easy,
    required this.medium,
    required this.hard,
    required this.contestRating,
  });

  factory LeetCodeStats.fromJson(Map<String, dynamic> json) {
    return LeetCodeStats(
      totalSolved: json['totalSolved'] ?? 0,
      easy: json['easy'] ?? 0,
      medium: json['medium'] ?? 0,
      hard: json['hard'] ?? 0,
      contestRating: json['contestRating'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSolved': totalSolved,
      'easy': easy,
      'medium': medium,
      'hard': hard,
      'contestRating': contestRating,
    };
  }
}

class CodeforcesStats {
  final int rating;
  final String rank;

  CodeforcesStats({
    required this.rating,
    required this.rank,
  });

  factory CodeforcesStats.fromJson(Map<String, dynamic> json) {
    return CodeforcesStats(
      rating: json['rating'] ?? 0,
      rank: json['rank'] ?? 'Unrated',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'rank': rank,
    };
  }
}

class CodeChefStats {
  final int rating;
  final int stars;

  CodeChefStats({
    required this.rating,
    required this.stars,
  });

  factory CodeChefStats.fromJson(Map<String, dynamic> json) {
    return CodeChefStats(
      rating: json['rating'] ?? 0,
      stars: json['stars'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'stars': stars,
    };
  }
}

class GFGStats {
  final int totalSolved;
  final int score;

  GFGStats({
    required this.totalSolved,
    required this.score,
  });

  factory GFGStats.fromJson(Map<String, dynamic> json) {
    return GFGStats(
      totalSolved: json['totalSolved'] ?? 0,
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSolved': totalSolved,
      'score': score,
    };
  }
}
