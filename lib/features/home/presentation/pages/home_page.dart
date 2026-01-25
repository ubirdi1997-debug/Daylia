import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checklist_provider.dart';
import '../../../checklist/presentation/pages/checklist_detail_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../widgets/checklist_card.dart';
import '../widgets/empty_state.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('Create Checklist'),
          ],
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter checklist title',
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref
                  .read(checklistListProvider.notifier)
                  .createChecklist(value.trim());
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                ref
                    .read(checklistListProvider.notifier)
                    .createChecklist(textController.text.trim());
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final currentSort = ref.read(sortOptionProvider);
        return AlertDialog(
          title: const Text('Sort By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<SortOption>(
                title: const Text('Recently Updated'),
                value: SortOption.recentlyUpdated,
                groupValue: currentSort,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(sortOptionProvider.notifier).state = value;
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<SortOption>(
                title: const Text('Alphabetical'),
                value: SortOption.alphabetical,
                groupValue: currentSort,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(sortOptionProvider.notifier).state = value;
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<SortOption>(
                title: const Text('Pinned First'),
                value: SortOption.pinnedFirst,
                groupValue: currentSort,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(sortOptionProvider.notifier).state = value;
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLongPress(String checklistId, bool isPinned) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              title: Text(isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                ref.read(checklistListProvider.notifier).togglePin(checklistId);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(checklistId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String checklistId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Checklist'),
        content: const Text('Are you sure you want to delete this checklist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(checklistListProvider.notifier)
                  .deleteChecklist(checklistId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checklist deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checklists = ref.watch(sortedChecklistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkly Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search checklists...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: checklists.isEmpty
                ? EmptyState(
                    onTap: _showCreateDialog,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: checklists.length,
                    itemBuilder: (context, index) {
                      final checklist = checklists[index];
                      return ChecklistCard(
                        checklist: checklist,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChecklistDetailPage(
                                checklistId: checklist.id,
                              ),
                            ),
                          );
                          // Refresh the list when returning
                          ref.read(checklistListProvider.notifier).refresh();
                        },
                        onLongPress: () => _handleLongPress(
                          checklist.id,
                          checklist.isPinned,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Checklist'),
      ),
    );
  }
}
