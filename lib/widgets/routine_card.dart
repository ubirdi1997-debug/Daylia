import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/routine.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completionPercent = routine.completionPercentage;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${routine.totalCompletedTasks}/${routine.tasks.length} tasks',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      }
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Streak Badge
              if (routine.currentStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.warningDark.withOpacity(0.2)
                        : AppColors.warningLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥'),
                      const SizedBox(width: 4),
                      Text(
                        '${routine.currentStreak} day${routine.currentStreak > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppColors.warningDark
                                  : AppColors.warningLight,
                            ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completionPercent,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    routine.allTasksCompleted
                        ? AppColors.successLight
                        : (isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Completion status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    routine.isCompletedToday
                        ? '✓ Completed today'
                        : 'Not completed',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: routine.isCompletedToday
                              ? AppColors.successLight
                              : AppColors.lightTextSecondary,
                        ),
                  ),
                  Text(
                    '${(completionPercent * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
