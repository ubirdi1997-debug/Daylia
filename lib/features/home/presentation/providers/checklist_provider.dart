import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/models/checklist.dart';
import '../../../../core/data/storage/checklist_storage.dart';

final checklistListProvider = StateNotifierProvider<ChecklistListNotifier, List<Checklist>>((ref) {
  return ChecklistListNotifier();
});

class ChecklistListNotifier extends StateNotifier<List<Checklist>> {
  ChecklistListNotifier() : super([]) {
    _loadChecklists();
  }

  void _loadChecklists() {
    state = ChecklistStorage.getAllChecklists();
  }

  void refresh() {
    _loadChecklists();
  }

  Future<void> createChecklist(String title) async {
    final checklist = Checklist(
      id: const Uuid().v4(),
      title: title,
      items: [],
      lastUpdated: DateTime.now(),
    );
    await ChecklistStorage.saveChecklist(checklist);
    _loadChecklists();
  }

  Future<void> updateChecklist(Checklist checklist) async {
    await ChecklistStorage.saveChecklist(checklist);
    _loadChecklists();
  }

  Future<void> deleteChecklist(String id) async {
    await ChecklistStorage.deleteChecklist(id);
    _loadChecklists();
  }

  Future<void> togglePin(String id) async {
    final checklist = ChecklistStorage.getChecklist(id);
    if (checklist != null) {
      final updated = checklist.copyWith(
        isPinned: !checklist.isPinned,
        lastUpdated: DateTime.now(),
      );
      await ChecklistStorage.saveChecklist(updated);
      _loadChecklists();
    }
  }

  Future<void> resetChecklist(String id) async {
    final checklist = ChecklistStorage.getChecklist(id);
    if (checklist != null) {
      checklist.reset();
      await ChecklistStorage.saveChecklist(checklist);
      _loadChecklists();
    }
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');

final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.recentlyUpdated);

enum SortOption {
  recentlyUpdated,
  alphabetical,
  pinnedFirst,
}

final sortedChecklistsProvider = Provider<List<Checklist>>((ref) {
  final checklists = ref.watch(checklistListProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final sortOption = ref.watch(sortOptionProvider);

  var filtered = checklists.where((checklist) {
    return checklist.title.toLowerCase().contains(searchQuery.toLowerCase());
  }).toList();

  switch (sortOption) {
    case SortOption.recentlyUpdated:
      filtered.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      break;
    case SortOption.alphabetical:
      filtered.sort((a, b) => a.title.compareTo(b.title));
      break;
    case SortOption.pinnedFirst:
      filtered.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.lastUpdated.compareTo(a.lastUpdated);
      });
      break;
  }

  return filtered;
});

