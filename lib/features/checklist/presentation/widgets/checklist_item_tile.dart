import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/data/models/checklist_item.dart';
import 'time_picker_dialog.dart';

class ChecklistItemTile extends StatefulWidget {
  final ChecklistItem item;
  final bool isCompleted;
  final bool canReorder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(DateTime?)? onReminderSet;

  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.isCompleted,
    this.canReorder = true,
    required this.onToggle,
    required this.onDelete,
    this.onReminderSet,
  });

  @override
  State<ChecklistItemTile> createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<ChecklistItemTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.isCompleted) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ChecklistItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatReminderTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(time.year, time.month, time.day);
    final isToday = reminderDate == today;
    final isTomorrow = reminderDate == today.add(const Duration(days: 1));

    final timeStr = TimeOfDay.fromDateTime(time).format(context);

    if (isToday) {
      return 'Today at $timeStr';
    } else if (isTomorrow) {
      return 'Tomorrow at $timeStr';
    } else {
      return '${time.day}/${time.month}/${time.year} at $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(widget.item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Item'),
            content: const Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) => widget.onDelete(),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isCompleted
                ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)
                : null,
            borderRadius: BorderRadius.circular(12),
            border: widget.isCompleted
                ? Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            children: [
              ListTile(
                leading: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: widget.item.isCompleted,
                    onChanged: (_) => widget.onToggle(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: BorderSide(
                      width: 2,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                title: Text(
                  widget.item.text,
                  style: TextStyle(
                    decoration:
                        widget.isCompleted ? TextDecoration.lineThrough : null,
                    color: widget.isCompleted
                        ? theme.colorScheme.onSurface.withOpacity(0.5)
                        : theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: widget.isCompleted ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.item.hasReminder && !widget.isCompleted)
                      IconButton(
                        icon: Icon(
                          widget.item.isReminderDue
                              ? Icons.notifications_active
                              : Icons.notifications,
                          color: widget.item.isReminderDue
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          size: 20,
                        ),
                        onPressed: widget.onReminderSet != null
                            ? () async {
                                final result = await showDialog<DateTime?>(
                                  context: context,
                                  builder: (context) => ReminderTimePickerDialog(
                                    initialTime: widget.item.reminderTime,
                                  ),
                                );
                                if (widget.onReminderSet != null) {
                                  widget.onReminderSet!(result);
                                }
                              }
                            : null,
                        tooltip: 'Edit reminder',
                      ),
                    if (!widget.item.hasReminder && !widget.isCompleted)
                      IconButton(
                        icon: Icon(
                          Icons.notifications_none,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          size: 20,
                        ),
                        onPressed: widget.onReminderSet != null
                            ? () async {
                                final result = await showDialog<DateTime?>(
                                  context: context,
                                  builder: (context) => const ReminderTimePickerDialog(),
                                );
                                if (widget.onReminderSet != null) {
                                  widget.onReminderSet!(result);
                                }
                              }
                            : null,
                        tooltip: 'Set reminder',
                      ),
                    if (widget.canReorder)
                      Icon(
                        Icons.drag_handle,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                minVerticalPadding: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              if (widget.item.hasReminder && !widget.isCompleted)
                Padding(
                  padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: widget.item.isReminderDue
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatReminderTime(widget.item.reminderTime!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.item.isReminderDue
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.item.isReminderDue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Due',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (widget.onReminderSet != null)
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onReminderSet!(null);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Remove',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

