class LeaderboardEntry {
  final int rank;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final int xp;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.xp,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank']?.toString() ?? '') ?? 0,
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['userId']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      xp: json['xp'] is int ? json['xp'] : int.tryParse(json['xp']?.toString() ?? '') ?? 0,
    );
  }
}

class UserBadge {
  final String badgeId;
  final String name;
  final String earnedAt;

  UserBadge({
    required this.badgeId,
    required this.name,
    required this.earnedAt,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      badgeId: json['badgeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      earnedAt: json['earnedAt']?.toString() ?? '',
    );
  }
}

class GamificationSummary {
  final String userId;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final List<UserBadge> badges;

  GamificationSummary({
    required this.userId,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.badges,
  });

  factory GamificationSummary.fromJson(Map<String, dynamic> json) {
    return GamificationSummary(
      userId: json['userId']?.toString() ?? '',
      totalXp: json['totalXp'] is int ? json['totalXp'] : int.tryParse(json['totalXp']?.toString() ?? '') ?? 0,
      currentStreak: json['currentStreak'] is int ? json['currentStreak'] : int.tryParse(json['currentStreak']?.toString() ?? '') ?? 0,
      longestStreak: json['longestStreak'] is int ? json['longestStreak'] : int.tryParse(json['longestStreak']?.toString() ?? '') ?? 0,
      badges: (json['badges'] as List? ?? [])
          .map((item) => UserBadge.fromJson(item))
          .toList(),
    );
  }
}
