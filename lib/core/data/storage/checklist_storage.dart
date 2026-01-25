import 'package:hive_flutter/hive_flutter.dart';
import '../models/checklist.dart';

class ChecklistStorage {
  static const String _boxName = 'checklists';
  static Box<Checklist>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<Checklist>(_boxName);
  }

  static Box<Checklist> get box {
    if (_box == null) {
      throw Exception('ChecklistStorage not initialized. Call init() first.');
    }
    return _box!;
  }

  static List<Checklist> getAllChecklists() {
    return _box!.values.toList();
  }

  static Checklist? getChecklist(String id) {
    return _box!.get(id);
  }

  static Future<void> saveChecklist(Checklist checklist) async {
    await _box!.put(checklist.id, checklist);
  }

  static Future<void> deleteChecklist(String id) async {
    await _box!.delete(id);
  }

  static Future<void> deleteAll() async {
    await _box!.clear();
  }
}

