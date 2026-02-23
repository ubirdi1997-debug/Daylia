import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/routine_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_progress_circle.dart';
import 'add_edit_routine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  double _calculateOverallCompletion(List routines) {
    if (routines.isEmpty) return 0;
    double total = 0;
    for (final routine in routines) {
      total += routine.completionPercentage;
    }
    return total / routines.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<RoutineProvider>(
        builder: (context, routineProvider, _) {
          final routines = routineProvider.routines;
          final overallCompletion = _calculateOverallCompletion(routines);

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
                title: Text(_getGreeting()),
              ),
              // Progress Circle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedProgressCircle(
                    percentage: overallCompletion,
                    size: 120,
                    routineName: 'Today\'s Progress',
                  ),
                ),
              ),
              // Quick Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickStat(
                        context,
                        '${routines.length}',
                        'Routines',
                      ),
                      _buildQuickStat(
                        context,
                        '${routines.where((r) => r.isCompletedToday).length}',
                        'Completed',
                      ),
                      _buildQuickStat(
                        context,
                        '${routineProvider.stats?.bestStreak ?? 0}',
                        'Best Streak',
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Routines List
              if (routines.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    title: 'No routines yet',
                    description: 'Create your first routine to get started',
                    icon: Icons.add_circle_outline,
                    actionLabel: 'Create Routine',
                    onActionPressed: () {
                      _openAddRoutine(context);
                    },
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
                      child: RoutineCard(
                        routine: routine,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/routine-detail',
                            arguments: routine.id,
                          );
                        },
                        onEdit: () {
                          _openAddRoutine(context, routineId: routine.id);
                        },
                        onDelete: () {
                          _showDeleteConfirmation(context, routine.name, () {
                            routineProvider.deleteRoutine(routine.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${routine.name} deleted'),
                              ),
                            );
                          });
                        },
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

  Widget _buildQuickStat(BuildContext context, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  void _openAddRoutine(BuildContext context, {String? routineId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditRoutineScreen(routineId: routineId),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String routineName,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Routine'),
        content: Text('Are you sure you want to delete "$routineName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
