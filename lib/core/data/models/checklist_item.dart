import 'package:hive/hive.dart';

part 'checklist_item.g.dart';

@HiveType(typeId: 1)
class ChecklistItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  int order;

  @HiveField(4)
  DateTime? reminderTime;

  ChecklistItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
    required this.order,
    this.reminderTime,
  });

  ChecklistItem copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    int? order,
    DateTime? reminderTime,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  bool get hasReminder => reminderTime != null;
  
  bool get isReminderDue => reminderTime != null && 
      reminderTime!.isBefore(DateTime.now()) && 
      !isCompleted;
}

