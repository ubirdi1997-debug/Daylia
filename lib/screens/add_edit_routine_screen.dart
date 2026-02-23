import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/routine_provider.dart';
import '../theme/app_colors.dart';

class AddEditRoutineScreen extends StatefulWidget {
  final String? routineId;

  const AddEditRoutineScreen({super.key, this.routineId});

  @override
  State<AddEditRoutineScreen> createState() => _AddEditRoutineScreenState();
}

class _AddEditRoutineScreenState extends State<AddEditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  bool _didLoad = false;
  bool _isSaving = false;
  List<Task> _tasks = [];

  @override
  void dispose() {
    _nameController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;

    if (widget.routineId != null) {
      final routine =
          context.read<RoutineProvider>().getRoutineById(widget.routineId!);
      if (routine != null) {
        _nameController.text = routine.name;
        _tasks = routine.tasks.map((task) => task.copyWith()).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      }
    }
  }

  void _addTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.add(Task(title: text, order: _tasks.length));
      _taskController.clear();
    });
  }

  void _removeTask(Task task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
      for (int i = 0; i < _tasks.length; i++) {
        _tasks[i] = _tasks[i].copyWith(order: i);
      }
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final trimmedName = _nameController.text.trim();
    final orderedTasks = _tasks.asMap().entries.map((entry) {
      return entry.value.copyWith(order: entry.key);
    }).toList();

    final provider = context.read<RoutineProvider>();

    try {
      if (widget.routineId != null) {
        final routine = provider.getRoutineById(widget.routineId!);
        if (routine != null) {
          await provider.updateRoutine(
            routine.copyWith(name: trimmedName, tasks: orderedTasks),
          );
        }
      } else {
        await provider.addRoutine(trimmedName, tasks: orderedTasks);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.routineId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Routine' : 'New Routine'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: Semantics(
                      label: 'Saving routine',
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Routine name',
                  hintText: 'Morning Reset',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        hintText: 'Add a task',
                      ),
                      onSubmitted: (_) => _addTask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_tasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'No tasks yet. Add tasks and drag to reorder.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tasks.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    setState(() {
                      final task = _tasks.removeAt(oldIndex);
                      _tasks.insert(newIndex, task);
                      for (int i = 0; i < _tasks.length; i++) {
                        _tasks[i] = _tasks[i].copyWith(order: i);
                      }
                    });
                  },
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      key: ValueKey(task.id),
                      child: ListTile(
                        title: Text(task.title),
                        leading: const Icon(Icons.drag_handle),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeTask(task),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
