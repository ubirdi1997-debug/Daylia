import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/task.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ValueChanged<String> onRename;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onRename,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onCheckboxTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: widget.task.isCompleted,
              onChanged: (_) => _onCheckboxTap(),
              side: BorderSide(
                color: widget.task.isCompleted
                    ? AppColors.successLight
                    : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
                width: 2.5,
              ),
            ),
          ),
          title: Text(
            widget.task.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              decoration: widget.task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: widget.task.isCompleted
                  ? AppColors.lightTextSecondary
                  : null,
            ),
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Delete'),
                onTap: widget.onDelete,
              ),
            ],
          ),
          onTap: _onCheckboxTap,
        ),
      ),
    );
  }
}
