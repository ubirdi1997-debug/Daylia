import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'task.dart';

part 'routine.g.dart';

@HiveType(typeId: 0)
class Routine extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Task> tasks;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime lastCompletedAt;

  @HiveField(5)
  int currentStreak;

  @HiveField(6)
  int bestStreak;

  @HiveField(7)
  String color;

  @HiveField(8)
  String icon;

  Routine({
    String? id,
    required this.name,
    List<Task>? tasks,
    DateTime? createdAt,
    DateTime? lastCompletedAt,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.color = 'indigo',
    this.icon = 'check_circle',
  })  : id = id ?? const Uuid().v4(),
        tasks = tasks ?? [],
        createdAt = createdAt ?? DateTime.now(),
        // Default lastCompletedAt to epoch to avoid false "completed today" on creation
        lastCompletedAt =
            lastCompletedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  bool get isCompletedToday {
    final now = DateTime.now();
    return lastCompletedAt.year == now.year &&
        lastCompletedAt.month == now.month &&
        lastCompletedAt.day == now.day;
  }

  bool get allTasksCompleted {
    if (tasks.isEmpty) return false;
    return tasks.every((task) => task.isCompleted);
  }

  double get completionPercentage {
    if (tasks.isEmpty) return 0;
    final completed = tasks.where((task) => task.isCompleted).length;
    return completed / tasks.length;
  }

  int get totalCompletedTasks {
    return tasks.where((task) => task.isCompleted).length;
  }

  Routine copyWith({
    String? id,
    String? name,
    List<Task>? tasks,
    DateTime? createdAt,
    DateTime? lastCompletedAt,
    int? currentStreak,
    int? bestStreak,
    String? color,
    String? icon,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      tasks: tasks ?? this.tasks,
      createdAt: createdAt ?? this.createdAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'lastCompletedAt': lastCompletedAt.toIso8601String(),
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'color': color,
        'icon': icon,
      };

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      tasks:
          (json['tasks'] as List).map((task) => Task.fromJson(task)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastCompletedAt: DateTime.parse(json['lastCompletedAt']),
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      color: json['color'] ?? 'indigo',
      icon: json['icon'] ?? 'check_circle',
    );
  }
}
