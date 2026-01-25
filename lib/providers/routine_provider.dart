import 'package:flutter/material.dart';
import '../models/routine.dart';
import '../models/task.dart';
import '../models/app_stats.dart';
import '../services/database_service.dart';

class RoutineProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Routine> _routines = [];
  AppStats? _stats;

  List<Routine> get routines => _routines;
  AppStats? get stats => _stats;

  RoutineProvider() {
    initialize();
  }

  Future<void> initialize() async {
    await _databaseService.initialize();
    await _databaseService.resetDailyRoutinesIfNeeded();
    await loadRoutines();
    updateStats();
  }

  Future<void> loadRoutines() async {
    _routines = _databaseService.getAllRoutines().map((routine) {
      routine.tasks.sort((a, b) => a.order.compareTo(b.order));
      return routine;
    }).toList();
    notifyListeners();
  }

  Future<String> addRoutine(String name, {List<Task>? tasks}) async {
    final routine = Routine(name: name, tasks: tasks ?? []);
    await _databaseService.addRoutine(routine);
    await loadRoutines();
    return routine.id;
  }

  Future<void> updateRoutine(Routine routine) async {
    await _databaseService.updateRoutine(routine);
    await loadRoutines();
  }

  Future<void> deleteRoutine(String id) async {
    await _databaseService.deleteRoutine(id);
    await loadRoutines();
  }

  Routine? getRoutineById(String id) {
    try {
      return _routines.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addTaskToRoutine(String routineId, String taskTitle) async {
    final task = Task(
      title: taskTitle,
      order: _databaseService.getRoutineById(routineId)?.tasks.length ?? 0,
    );
    await _databaseService.addTask(routineId, task);
    await loadRoutines();
  }

  Future<void> updateTask(String routineId, Task task) async {
    await _databaseService.updateTask(routineId, task);
    await loadRoutines();
  }

  Future<void> toggleTask(String routineId, Task task) async {
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    await _databaseService.updateTask(routineId, task);

    final routine = _databaseService.getRoutineById(routineId);
    if (routine != null && routine.allTasksCompleted) {
      final now = DateTime.now();
      final alreadyCompletedToday = routine.isCompletedToday;
      routine.lastCompletedAt = now;
      if (!alreadyCompletedToday) {
        routine.currentStreak += 1;
        if (routine.currentStreak > routine.bestStreak) {
          routine.bestStreak = routine.currentStreak;
        }
      }
      await _databaseService.updateRoutine(routine);
    }

    await loadRoutines();
    updateStats();
  }

  Future<void> deleteTask(String routineId, String taskId) async {
    await _databaseService.deleteTask(routineId, taskId);
    await loadRoutines();
  }

  Future<void> reorderTasks(String routineId, List<Task> tasks) async {
    for (int i = 0; i < tasks.length; i++) {
      tasks[i].order = i;
    }
    await _databaseService.reorderTasks(routineId, tasks);
    await loadRoutines();
  }

  Future<void> completeRoutine(String routineId) async {
    final routine = _databaseService.getRoutineById(routineId);
    if (routine != null && routine.allTasksCompleted) {
      final now = DateTime.now();
      final alreadyCompletedToday = routine.isCompletedToday;
      routine.lastCompletedAt = now;
      if (!alreadyCompletedToday) {
        routine.currentStreak += 1;
        if (routine.currentStreak > routine.bestStreak) {
          routine.bestStreak = routine.currentStreak;
        }
      }
      await _databaseService.updateRoutine(routine);
      await loadRoutines();
      updateStats();
    }
  }

  Future<void> resetDailyRoutines() async {
    await _databaseService.resetDailyRoutines();
    await loadRoutines();
    updateStats();
  }

  void updateStats() {
    _stats = AppStats(
      totalCompletedTasks: _databaseService.getTotalCompletedTasks(),
      weeklyCompletionPercentage:
          _databaseService.getWeeklyCompletionPercentage(),
      bestStreak: _databaseService.getBestStreak(),
      currentDay: DateTime.now().day,
    );
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _databaseService.clearAllData();
    await loadRoutines();
    updateStats();
  }
}
