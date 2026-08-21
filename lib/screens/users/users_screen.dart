import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/bmi/bmi_badge.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_error_states.dart';
import '../../widgets/dialogs/confirm_delete_dialog.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';
import 'user_detail_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<UserProvider>().load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddUserScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add User'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          provider.setSearch('');
                        },
                      ),
              ),
              onChanged: (v) => provider.setSearch(v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: provider.genderFilter,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['All', 'Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => provider.setGenderFilter(v ?? 'All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: provider.categoryFilter,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ['All', 'Underweight', 'Normal', 'Overweight', 'Obese']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => provider.setCategoryFilter(v ?? 'All'),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _SortChip(
                    label: 'Name',
                    field: SortField.name,
                    provider: provider),
                _SortChip(
                    label: 'Age', field: SortField.age, provider: provider),
                _SortChip(
                    label: 'BMI', field: SortField.bmi, provider: provider),
                _SortChip(
                    label: 'Date Added',
                    field: SortField.dateAdded,
                    provider: provider),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Builder(builder: (context) {
              if (provider.isLoading && provider.records.isEmpty) {
                return const LoadingState();
              }
              if (provider.errorMessage != null) {
                return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: () => provider.load());
              }
              if (provider.records.isEmpty) {
                return const EmptyState(title: 'No records found');
              }
              return RefreshIndicator(
                onRefresh: () => provider.load(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final r = provider.records[index];
                    return Card(
                      child: ListTile(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => UserDetailScreen(userId: r.id)),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          '${r.gender.label} • Age ${r.age} • ${DateFormat('MMM d, yyyy').format(r.createdAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BmiBadge(bmi: r.bmi, category: r.bmiCategory, compact: true),
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              onSelected: (value) async {
                                if (value == 'view') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) =>
                                          UserDetailScreen(userId: r.id)));
                                } else if (value == 'edit') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => EditUserScreen(user: r)));
                                } else if (value == 'delete') {
                                  final confirmed =
                                      await showConfirmDeleteDialog(context);
                                  if (confirmed) {
                                    final ok = await provider.deleteUser(r.id);
                                    if (context.mounted) {
                                      showAppSnackBar(
                                        context,
                                        ok
                                            ? 'User deleted'
                                            : (provider.errorMessage ??
                                                'Delete failed'),
                                        isError: !ok,
                                      );
                                    }
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: 'view', child: Text('View')),
                                const PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                if (isAdmin)
                                  const PopupMenuItem(
                                      value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final SortField field;
  final UserProvider provider;

  const _SortChip(
      {required this.label, required this.field, required this.provider});

  @override
  Widget build(BuildContext context) {
    final active = provider.sortField == field;
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (active) ...[
              const SizedBox(width: 4),
              Icon(
                provider.ascending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
              ),
            ],
          ],
        ),
        selected: active,
        onSelected: (_) => provider.setSort(field),
      ),
    );
  }
}
