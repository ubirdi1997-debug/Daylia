import 'package:hive/hive.dart';
import 'checklist_item.dart';

part 'checklist.g.dart';

@HiveType(typeId: 0)
class Checklist extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<ChecklistItem> items;

  @HiveField(3)
  bool isPinned;

  @HiveField(4)
  DateTime lastUpdated;

  Checklist({
    required this.id,
    required this.title,
    required this.items,
    this.isPinned = false,
    required this.lastUpdated,
  });

  int get completedCount => items.where((item) => item.isCompleted).length;
  
  int get totalCount => items.length;
  
  double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;

  Checklist copyWith({
    String? id,
    String? title,
    List<ChecklistItem>? items,
    bool? isPinned,
    DateTime? lastUpdated,
  }) {
    return Checklist(
      id: id ?? this.id,
      title: title ?? this.title,
      items: items ?? this.items,
      isPinned: isPinned ?? this.isPinned,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  void reset() {
    for (var item in items) {
      item.isCompleted = false;
    }
    lastUpdated = DateTime.now();
  }
}

