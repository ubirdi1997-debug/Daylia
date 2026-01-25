class AppStats {
  final int totalCompletedTasks;
  final double weeklyCompletionPercentage;
  final int bestStreak;
  final int currentDay;

  AppStats({
    required this.totalCompletedTasks,
    required this.weeklyCompletionPercentage,
    required this.bestStreak,
    required this.currentDay,
  });

  AppStats copyWith({
    int? totalCompletedTasks,
    double? weeklyCompletionPercentage,
    int? bestStreak,
    int? currentDay,
  }) {
    return AppStats(
      totalCompletedTasks: totalCompletedTasks ?? this.totalCompletedTasks,
      weeklyCompletionPercentage:
          weeklyCompletionPercentage ?? this.weeklyCompletionPercentage,
      bestStreak: bestStreak ?? this.bestStreak,
      currentDay: currentDay ?? this.currentDay,
    );
  }
}
