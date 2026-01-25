import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine.dart';
import '../models/task.dart';

class DatabaseService {
  static const String routineBoxName = 'routines';
  static const String settingsBoxName = 'settings';

  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  late Box<Routine> _routineBox;
  late Box _settingsBox;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RoutineAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }

    _routineBox = await Hive.openBox<Routine>(routineBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    _initialized = true;
  }

  Box<Routine> get routineBox => _routineBox;
  Box get settingsBox => _settingsBox;

  // Routine Operations
  Future<void> addRoutine(Routine routine) async {
    await _routineBox.put(routine.id, routine);
  }

  Future<void> updateRoutine(Routine routine) async {
    await _routineBox.put(routine.id, routine);
  }

  Future<void> deleteRoutine(String id) async {
    await _routineBox.delete(id);
  }

  List<Routine> getAllRoutines() {
    return _routineBox.values.toList();
  }

  Routine? getRoutineById(String id) {
    return _routineBox.get(id);
  }

  // Task Operations
  Future<void> updateTask(String routineId, Task task) async {
    final routine = _routineBox.get(routineId);
    if (routine != null) {
      final taskIndex = routine.tasks.indexWhere((t) => t.id == task.id);
      if (taskIndex != -1) {
        routine.tasks[taskIndex] = task;
        await _routineBox.put(routineId, routine);
      }
    }
  }

  Future<void> addTask(String routineId, Task task) async {
    final routine = _routineBox.get(routineId);
    if (routine != null) {
      routine.tasks.add(task);
      await _routineBox.put(routineId, routine);
    }
  }

  Future<void> deleteTask(String routineId, String taskId) async {
    final routine = _routineBox.get(routineId);
    if (routine != null) {
      routine.tasks.removeWhere((task) => task.id == taskId);
      await _routineBox.put(routineId, routine);
    }
  }

  Future<void> reorderTasks(String routineId, List<Task> reorderedTasks) async {
    final routine = _routineBox.get(routineId);
    if (routine != null) {
      routine.tasks.clear();
      routine.tasks.addAll(reorderedTasks);
      await _routineBox.put(routineId, routine);
    }
  }

  // Daily Reset
  Future<void> resetDailyRoutines() async {
    final routines = _routineBox.values.toList();
    final now = DateTime.now();

    for (final routine in routines) {
      final lastCompleted = routine.lastCompletedAt;

      // Check if this routine was completed yesterday
      final yesterday = DateTime(now.year, now.month, now.day).subtract(
        const Duration(days: 1),
      );
      final wasCompletedYesterday = lastCompleted.year == yesterday.year &&
          lastCompleted.month == yesterday.month &&
          lastCompleted.day == yesterday.day;

      if (wasCompletedYesterday) {
        // Maintain streak
        routine.currentStreak = routine.currentStreak + 1;
        if (routine.currentStreak > routine.bestStreak) {
          routine.bestStreak = routine.currentStreak;
        }
      } else if (!routine.isCompletedToday) {
        // Reset streak if not completed today and not yesterday
        routine.currentStreak = 0;
      }

      // Reset all tasks
      for (final task in routine.tasks) {
        task.isCompleted = false;
        task.completedAt = null;
      }

      await _routineBox.put(routine.id, routine);
    }
  }

  Future<void> resetDailyRoutinesIfNeeded() async {
    final today = DateTime.now();
    final todayKey =
        DateTime(today.year, today.month, today.day).toIso8601String();
    final lastReset = _settingsBox.get('lastResetDate') as String?;

    if (lastReset == todayKey) {
      return;
    }

    await resetDailyRoutines();
    await _settingsBox.put('lastResetDate', todayKey);
  }

  // Statistics
  int getTotalCompletedTasks() {
    int total = 0;
    for (final routine in _routineBox.values) {
      total += routine.totalCompletedTasks;
    }
    return total;
  }

  double getWeeklyCompletionPercentage() {
    final routines = _routineBox.values.toList();
    if (routines.isEmpty) return 0;

    int totalTasks = 0;
    int completedTasks = 0;

    for (final routine in routines) {
      totalTasks += routine.tasks.length;
      completedTasks += routine.totalCompletedTasks;
    }

    if (totalTasks == 0) return 0;
    return (completedTasks / totalTasks) * 100;
  }

  int getBestStreak() {
    int best = 0;
    for (final routine in _routineBox.values) {
      if (routine.bestStreak > best) {
        best = routine.bestStreak;
      }
    }
    return best;
  }

  Future<void> clearAllData() async {
    await _routineBox.clear();
  }
}
