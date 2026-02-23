import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_progress_circle.dart';
import '../widgets/streak_badge.dart';
import '../widgets/task_tile.dart';
import 'add_edit_routine_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  final String routineId;

  const RoutineDetailScreen({super.key, required this.routineId});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  late TextEditingController _taskController;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<RoutineProvider>(
      builder: (context, routineProvider, _) {
        final routine = routineProvider.getRoutineById(widget.routineId);

        if (routine == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Routine not found')),
            body: const Center(child: Text('This routine no longer exists')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                title: Text(routine.name),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditRoutineScreen(
                            routineId: routine.id,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // Progress & Streak Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      AnimatedProgressCircle(
                        percentage: routine.completionPercentage,
                        size: 140,
                        routineName: 'Today\'s Progress',
                      ),
                      const SizedBox(height: 24),
                      // Streak Info
                      if (routine.currentStreak > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StreakBadge(
                              streak: routine.currentStreak,
                              large: true,
                            ),
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Streak',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${routine.currentStreak} day${routine.currentStreak > 1 ? 's' : ''}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Best: ${routine.bestStreak} days',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Tasks Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tasks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${routine.totalCompletedTasks}/${routine.tasks.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              // Task List with reorder support
              if (routine.tasks.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.playlist_add_check,
                            size: 48,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks yet',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: routine.tasks.length,
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final updatedTasks = List<Task>.from(routine.tasks);
                        final task = updatedTasks.removeAt(oldIndex);
                        updatedTasks.insert(newIndex, task);
                        routineProvider.reorderTasks(
                          routine.id,
                          updatedTasks,
                        );
                      },
                      itemBuilder: (context, index) {
                        final task = routine.tasks[index];
                        return Padding(
                          key: ValueKey(task.id),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: TaskTile(
                            task: task,
                            onToggle: () {
                              routineProvider.toggleTask(routine.id, task);
                            },
                            onDelete: () {
                              routineProvider.deleteTask(routine.id, task.id);
                            },
                            onRename: (newTitle) {
                              final updatedTask =
                                  task.copyWith(title: newTitle);
                              routineProvider.updateTask(
                                routine.id,
                                updatedTask,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTaskDialog(context, routine.id),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, String routineId) {
    _taskController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: _taskController,
          decoration: const InputDecoration(hintText: 'Task description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = _taskController.text.trim();
              if (text.isNotEmpty) {
                context.read<RoutineProvider>().addTaskToRoutine(
                      routineId,
                      text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
