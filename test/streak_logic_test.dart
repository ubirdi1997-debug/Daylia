import 'package:flutter_test/flutter_test.dart';
import 'package:Daylia/models/routine.dart';
import 'package:Daylia/models/task.dart';

void main() {
  group('Task model', () {
    test('creates task with defaults', () {
      final task = Task(title: 'Morning run');
      expect(task.title, 'Morning run');
      expect(task.isCompleted, false);
      expect(task.order, 0);
      expect(task.completedAt, null);
      expect(task.id, isNotEmpty);
    });

    test('copyWith preserves fields', () {
      final task = Task(title: 'Read', order: 2);
      final updated = task.copyWith(isCompleted: true, title: 'Read book');
      expect(updated.id, task.id);
      expect(updated.title, 'Read book');
      expect(updated.isCompleted, true);
      expect(updated.order, 2);
    });

    test('JSON round-trip', () {
      final task = Task(title: 'Meditate', isCompleted: true, order: 1);
      final json = task.toJson();
      final restored = Task.fromJson(json);
      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.isCompleted, task.isCompleted);
      expect(restored.order, task.order);
    });
  });

  group('Routine model', () {
    test('creates routine with defaults', () {
      final routine = Routine(name: 'Morning');
      expect(routine.name, 'Morning');
      expect(routine.tasks, isEmpty);
      expect(routine.currentStreak, 0);
      expect(routine.bestStreak, 0);
      expect(routine.id, isNotEmpty);
    });

    test('isCompletedToday returns false for epoch lastCompletedAt', () {
      final routine = Routine(name: 'Morning');
      expect(routine.isCompletedToday, false);
    });

    test('isCompletedToday returns true when lastCompletedAt is today', () {
      final now = DateTime.now();
      final routine = Routine(name: 'Morning', lastCompletedAt: now);
      expect(routine.isCompletedToday, true);
    });

    test('isCompletedToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final routine = Routine(name: 'Morning', lastCompletedAt: yesterday);
      expect(routine.isCompletedToday, false);
    });

    test('allTasksCompleted returns false when tasks list is empty', () {
      final routine = Routine(name: 'Morning');
      expect(routine.allTasksCompleted, false);
    });

    test('allTasksCompleted returns false when some tasks incomplete', () {
      final tasks = [
        Task(title: 'Task 1', isCompleted: true),
        Task(title: 'Task 2', isCompleted: false),
      ];
      final routine = Routine(name: 'Morning', tasks: tasks);
      expect(routine.allTasksCompleted, false);
    });

    test('allTasksCompleted returns true when all tasks complete', () {
      final tasks = [
        Task(title: 'Task 1', isCompleted: true),
        Task(title: 'Task 2', isCompleted: true),
      ];
      final routine = Routine(name: 'Morning', tasks: tasks);
      expect(routine.allTasksCompleted, true);
    });

    test('completionPercentage is 0 for empty routine', () {
      final routine = Routine(name: 'Morning');
      expect(routine.completionPercentage, 0.0);
    });

    test('completionPercentage is correct for partial completion', () {
      final tasks = [
        Task(title: 'Task 1', isCompleted: true),
        Task(title: 'Task 2', isCompleted: false),
        Task(title: 'Task 3', isCompleted: false),
        Task(title: 'Task 4', isCompleted: true),
      ];
      final routine = Routine(name: 'Morning', tasks: tasks);
      expect(routine.completionPercentage, 0.5);
    });

    test('completionPercentage is 1.0 when all tasks done', () {
      final tasks = [
        Task(title: 'Task 1', isCompleted: true),
        Task(title: 'Task 2', isCompleted: true),
      ];
      final routine = Routine(name: 'Morning', tasks: tasks);
      expect(routine.completionPercentage, 1.0);
    });

    test('totalCompletedTasks counts correctly', () {
      final tasks = [
        Task(title: 'T1', isCompleted: true),
        Task(title: 'T2', isCompleted: false),
        Task(title: 'T3', isCompleted: true),
      ];
      final routine = Routine(name: 'Morning', tasks: tasks);
      expect(routine.totalCompletedTasks, 2);
    });

    test('copyWith creates new routine preserving fields', () {
      final routine = Routine(name: 'Morning', currentStreak: 5);
      final updated = routine.copyWith(name: 'Evening', bestStreak: 10);
      expect(updated.id, routine.id);
      expect(updated.name, 'Evening');
      expect(updated.currentStreak, 5);
      expect(updated.bestStreak, 10);
    });

    test('JSON round-trip preserves all fields', () {
      final tasks = [Task(title: 'Wake up', isCompleted: true)];
      final now = DateTime.now();
      final routine = Routine(
        name: 'Morning',
        tasks: tasks,
        currentStreak: 3,
        bestStreak: 7,
        lastCompletedAt: now,
      );
      final json = routine.toJson();
      final restored = Routine.fromJson(json);
      expect(restored.id, routine.id);
      expect(restored.name, routine.name);
      expect(restored.currentStreak, routine.currentStreak);
      expect(restored.bestStreak, routine.bestStreak);
      expect(restored.tasks.length, 1);
      expect(restored.tasks.first.title, 'Wake up');
    });
  });

  group('Streak logic', () {
    test('streak starts at 0', () {
      final routine = Routine(name: 'Test');
      expect(routine.currentStreak, 0);
      expect(routine.bestStreak, 0);
    });

    test('bestStreak updates when currentStreak exceeds it', () {
      final routine = Routine(name: 'Test', currentStreak: 5, bestStreak: 3);
      // Simulate streak logic: if currentStreak > bestStreak, update bestStreak
      final newStreak = routine.currentStreak + 1;
      final newBest =
          newStreak > routine.bestStreak ? newStreak : routine.bestStreak;
      expect(newBest, 6);
    });

    test('bestStreak does not decrease when currentStreak is lower', () {
      final routine = Routine(name: 'Test', currentStreak: 2, bestStreak: 10);
      final newStreak = routine.currentStreak + 1;
      final newBest =
          newStreak > routine.bestStreak ? newStreak : routine.bestStreak;
      expect(newBest, 10);
    });

    test('daily reset: streak resets when not completed yesterday', () {
      // A routine that was last completed 5 days ago should have streak reset to 0
      final fiveDaysAgo =
          DateTime.now().subtract(const Duration(days: 5));
      final routine = Routine(
        name: 'Test',
        lastCompletedAt: fiveDaysAgo,
        currentStreak: 5,
      );
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
      final wasCompletedYesterday =
          routine.lastCompletedAt.year == yesterday.year &&
          routine.lastCompletedAt.month == yesterday.month &&
          routine.lastCompletedAt.day == yesterday.day;
      final isCompletedToday = routine.isCompletedToday;

      int newStreak = routine.currentStreak;
      if (wasCompletedYesterday) {
        newStreak = routine.currentStreak + 1;
      } else if (!isCompletedToday) {
        newStreak = 0;
      }
      expect(newStreak, 0);
    });

    test('daily reset: streak increments when completed yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final routine = Routine(
        name: 'Test',
        lastCompletedAt: yesterday,
        currentStreak: 3,
      );
      final now = DateTime.now();
      final yesterdayDate =
          DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      final wasCompletedYesterday =
          routine.lastCompletedAt.year == yesterdayDate.year &&
          routine.lastCompletedAt.month == yesterdayDate.month &&
          routine.lastCompletedAt.day == yesterdayDate.day;

      int newStreak = routine.currentStreak;
      if (wasCompletedYesterday) {
        newStreak = routine.currentStreak + 1;
      }
      expect(newStreak, 4);
    });
  });

  group('Adding tasks', () {
    test('can add a task to a routine', () {
      final routine = Routine(name: 'Morning');
      expect(routine.tasks, isEmpty);

      final task = Task(title: 'Drink water', order: 0);
      final updated = routine.copyWith(tasks: [...routine.tasks, task]);
      expect(updated.tasks.length, 1);
      expect(updated.tasks.first.title, 'Drink water');
    });

    test('multiple tasks are ordered correctly', () {
      final tasks = List.generate(
        3,
        (i) => Task(title: 'Task $i', order: i),
      );
      final routine = Routine(name: 'Morning', tasks: tasks);
      for (int i = 0; i < routine.tasks.length; i++) {
        expect(routine.tasks[i].order, i);
      }
    });
  });

  group('Completing tasks', () {
    test('toggling task changes isCompleted', () {
      final task = Task(title: 'Exercise');
      expect(task.isCompleted, false);

      final toggled = task.copyWith(isCompleted: true);
      expect(toggled.isCompleted, true);

      final toggledBack = toggled.copyWith(isCompleted: false);
      expect(toggledBack.isCompleted, false);
    });

    test('completing all tasks makes allTasksCompleted true', () {
      final tasks = [
        Task(title: 'T1'),
        Task(title: 'T2'),
      ];
      final routine = Routine(name: 'Morning', tasks: tasks);
      expect(routine.allTasksCompleted, false);

      final completedTasks =
          tasks.map((t) => t.copyWith(isCompleted: true)).toList();
      final completedRoutine = routine.copyWith(tasks: completedTasks);
      expect(completedRoutine.allTasksCompleted, true);
    });
  });
}
