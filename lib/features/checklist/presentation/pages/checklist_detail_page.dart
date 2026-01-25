import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/models/checklist.dart';
import '../../../../core/data/models/checklist_item.dart';
import '../../../../core/data/storage/checklist_storage.dart';
import '../../../../core/services/notification_service.dart';
import '../../../home/presentation/providers/checklist_provider.dart';
import '../widgets/checklist_item_tile.dart';

class ChecklistDetailPage extends ConsumerStatefulWidget {
  final String checklistId;

  const ChecklistDetailPage({
    super.key,
    required this.checklistId,
  });

  @override
  ConsumerState<ChecklistDetailPage> createState() => _ChecklistDetailPageState();
}

class _ChecklistDetailPageState extends ConsumerState<ChecklistDetailPage> {
  final TextEditingController _itemController = TextEditingController();
  Checklist? _checklist;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  void _loadChecklist() {
    setState(() {
      _checklist = ChecklistStorage.getChecklist(widget.checklistId);
    });
  }

  void _saveChecklist() {
    if (_checklist != null) {
      final updated = _checklist!.copyWith(
        lastUpdated: DateTime.now(),
      );
      ref.read(checklistListProvider.notifier).updateChecklist(updated);
      _loadChecklist();
    }
  }

  void _addItem(String text) {
    if (text.trim().isEmpty || _checklist == null) return;

    final newItem = ChecklistItem(
      id: const Uuid().v4(),
      text: text.trim(),
      order: _checklist!.items.length,
    );

    setState(() {
      _checklist!.items.add(newItem);
      _checklist!.lastUpdated = DateTime.now();
    });

    _saveChecklist();
    _itemController.clear();
    HapticFeedback.lightImpact();
  }

  void _toggleItem(String itemId) {
    if (_checklist == null) return;

    setState(() {
      final item = _checklist!.items.firstWhere((i) => i.id == itemId);
      item.isCompleted = !item.isCompleted;
      _checklist!.lastUpdated = DateTime.now();
      
      // Cancel notification if item is completed
      if (item.isCompleted && item.hasReminder) {
        final notificationId = NotificationService.getNotificationId(item.id);
        NotificationService.cancelNotification(notificationId);
      }
    });

    _saveChecklist();
    HapticFeedback.selectionClick();
  }

  void _setReminder(String itemId, DateTime? reminderTime) {
    if (_checklist == null) return;

    setState(() {
      final item = _checklist!.items.firstWhere((i) => i.id == itemId);
      final oldReminderTime = item.reminderTime;
      item.reminderTime = reminderTime;
      _checklist!.lastUpdated = DateTime.now();
      
      // Cancel old notification if exists
      if (oldReminderTime != null) {
        final notificationId = NotificationService.getNotificationId(item.id);
        NotificationService.cancelNotification(notificationId);
      }
      
      // Schedule new notification if time is set
      if (reminderTime != null && !item.isCompleted) {
        final notificationId = NotificationService.getNotificationId(item.id);
        NotificationService.scheduleReminder(
          id: notificationId,
          title: _checklist!.title,
          body: item.text,
          scheduledTime: reminderTime,
        );
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder set for ${TimeOfDay.fromDateTime(reminderTime).format(context)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (reminderTime == null) {
        HapticFeedback.lightImpact();
      }
    });

    _saveChecklist();
  }

  void _deleteItem(String itemId) {
    if (_checklist == null) return;

    final item = _checklist!.items.firstWhere((i) => i.id == itemId);
    final itemText = item.text;

    // Cancel notification if exists
    if (item.hasReminder) {
      final notificationId = NotificationService.getNotificationId(item.id);
      NotificationService.cancelNotification(notificationId);
    }

    setState(() {
      _checklist!.items.removeWhere((i) => i.id == itemId);
      // Reorder remaining items
      for (int i = 0; i < _checklist!.items.length; i++) {
        _checklist!.items[i].order = i;
      }
      _checklist!.lastUpdated = DateTime.now();
    });

    _saveChecklist();
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: $itemText'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Restore item
            final restoredItem = ChecklistItem(
              id: itemId,
              text: itemText,
              isCompleted: item.isCompleted,
              order: item.order,
            );
            setState(() {
              _checklist!.items.insert(item.order, restoredItem);
              _checklist!.lastUpdated = DateTime.now();
            });
            _saveChecklist();
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (_checklist == null) return;

    // Only allow reordering of incomplete items
    final incompleteItems = _checklist!.items.where((i) => !i.isCompleted).toList();
    if (oldIndex >= incompleteItems.length || newIndex >= incompleteItems.length) {
      return;
    }

    setState(() {
      // Get the actual items from the checklist
      final allItems = _checklist!.items.toList();
      final incompleteIndices = <int>[];
      final completedItems = <ChecklistItem>[];
      
      for (int i = 0; i < allItems.length; i++) {
        if (allItems[i].isCompleted) {
          completedItems.add(allItems[i]);
        } else {
          incompleteIndices.add(i);
        }
      }
      
      // Reorder incomplete items
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = incompleteItems.removeAt(oldIndex);
      incompleteItems.insert(newIndex, item);
      
      // Rebuild the list with reordered incomplete items first, then completed
      _checklist!.items.clear();
      _checklist!.items.addAll(incompleteItems);
      _checklist!.items.addAll(completedItems);
      
      // Update order values
      for (int i = 0; i < _checklist!.items.length; i++) {
        _checklist!.items[i].order = i;
      }
      _checklist!.lastUpdated = DateTime.now();
    });

    _saveChecklist();
    HapticFeedback.lightImpact();
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Checklist'),
        content: const Text(
          'This will clear all checkmarks but keep the items. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_checklist != null) {
                setState(() {
                  _checklist!.reset();
                });
                _saveChecklist();
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Checklist reset'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checklist == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checklist')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final completedItems = _checklist!.items.where((i) => i.isCompleted).toList();
    final incompleteItems = _checklist!.items.where((i) => !i.isCompleted).toList();
    
    // Sort by order
    completedItems.sort((a, b) => a.order.compareTo(b.order));
    incompleteItems.sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(
        title: Text(_checklist!.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showResetDialog,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: incompleteItems.length + completedItems.length,
              onReorder: (oldIndex, newIndex) {
                // Only allow reordering if both indices are in incomplete items
                if (oldIndex < incompleteItems.length && newIndex < incompleteItems.length) {
                  _onReorder(oldIndex, newIndex);
                }
              },
              itemBuilder: (context, index) {
                ChecklistItem item;
                bool isCompleted;
                bool canReorder;
                
                if (index < incompleteItems.length) {
                  item = incompleteItems[index];
                  isCompleted = false;
                  canReorder = true;
                } else {
                  item = completedItems[index - incompleteItems.length];
                  isCompleted = true;
                  canReorder = false;
                }

                return ChecklistItemTile(
                  key: ValueKey(item.id),
                  item: item,
                  isCompleted: isCompleted,
                  canReorder: canReorder,
                  onToggle: () => _toggleItem(item.id),
                  onDelete: () => _deleteItem(item.id),
                  onReminderSet: (reminderTime) => _setReminder(item.id, reminderTime),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _itemController,
              decoration: InputDecoration(
                hintText: 'Add new item...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addItem(_itemController.text),
                ),
              ),
              onSubmitted: _addItem,
            ),
          ),
        ],
      ),
    );
  }
}

