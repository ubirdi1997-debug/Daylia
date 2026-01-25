import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<RoutineProvider>(
        builder: (context, routineProvider, _) {
          final stats = routineProvider.stats;
          final routines = routineProvider.routines;

          return CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                title: const Text('Statistics'),
              ),
              // Main Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          StatCard(
                            label: 'Total Tasks',
                            value: '${stats?.totalCompletedTasks ?? 0}',
                            icon: Icons.done_all,
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            label: 'Best Streak',
                            value: '${stats?.bestStreak ?? 0}',
                            icon: Icons.local_fire_department,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          StatCard(
                            label: 'Completion Rate',
                            value:
                                '${(stats?.weeklyCompletionPercentage ?? 0).toStringAsFixed(0)}%',
                            icon: Icons.trending_up,
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            label: 'Active Routines',
                            value: '${routines.length}',
                            icon: Icons.repeat,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Detailed Routines Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Routine Breakdown',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (routines.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No routines to display',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final routine = routines[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      routine.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (routine.currentStreak > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warningLight
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text('🔥'),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${routine.currentStreak}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildStat(
                                context,
                                'Tasks Completed',
                                '${routine.totalCompletedTasks}/${routine.tasks.length}',
                              ),
                              const SizedBox(height: 8),
                              _buildStat(
                                context,
                                'Completion',
                                '${(routine.completionPercentage * 100).toStringAsFixed(0)}%',
                              ),
                              const SizedBox(height: 8),
                              _buildStat(
                                context,
                                'Best Streak',
                                '${routine.bestStreak} days',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: routines.length),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
