import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../viewmodels/todo_viewmodel.dart';
import '../widgets/todo_filter.dart';
import '../widgets/todo_item.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key, this.viewModel});

  final TodoViewModel? viewModel;

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late final TodoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? TodoViewModel();
    _viewModel.loadTodos();
  }

  @override
  void dispose() {
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _showTodoEditor([Todo? todo]) async {
    final formKey = GlobalKey<FormState>();
    var draft = todo?.title ?? '';
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        void submit() {
          if (formKey.currentState!.validate()) {
            Navigator.of(context).pop(draft);
          }
        }

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                todo == null ? Icons.add_task_rounded : Icons.edit_note_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                todo == null ? 'Thêm công việc' : 'Sửa công việc',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              autofocus: true,
              initialValue: draft,
              decoration: InputDecoration(
                hintText: 'Nhập việc bạn cần làm...',
                labelText: 'Nội dung',
                prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 20),
              ),
              textInputAction: TextInputAction.done,
              onChanged: (value) => draft = value,
              onFieldSubmitted: (_) => submit(),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Hãy nhập nội dung công việc.'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
            ),
            FilledButton.icon(
              onPressed: submit,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Lưu'),
            ),
          ],
        );
      },
    );
    if (!mounted || title == null) return;

    if (todo == null) {
      await _viewModel.addTodo(title);
    } else {
      await _viewModel.editTodo(todo.id, title);
    }
  }

  Widget _buildStatCard({
    required String label,
    required String count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$label: $count',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.checklist_rounded, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Todo List',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTodoEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm công việc', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 3,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, child) {
                final todos = _viewModel.visibleTodos;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildStatCard(
                                label: 'Tổng',
                                count: '${_viewModel.totalCount}',
                                icon: Icons.folder_open_rounded,
                                color: const Color(0xFF4F46E5),
                                bgColor: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              _buildStatCard(
                                label: 'Chưa xong',
                                count: '${_viewModel.activeCount}',
                                icon: Icons.pending_actions_rounded,
                                color: const Color(0xFFD97706),
                                bgColor: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              _buildStatCard(
                                label: 'Đã xong',
                                count: '${_viewModel.completedCount}',
                                icon: Icons.check_circle_rounded,
                                color: const Color(0xFF059669),
                                bgColor: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TodoFilter(
                            selected: _viewModel.filter,
                            onChanged: _viewModel.setFilter,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: todos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Icon(
                                      _viewModel.totalCount == 0
                                          ? Icons.assignment_outlined
                                          : Icons.filter_alt_off_outlined,
                                      size: 48,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _viewModel.totalCount == 0
                                        ? 'Chưa có công việc nào.'
                                        : 'Không có công việc phù hợp bộ lọc.',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _viewModel.totalCount == 0
                                        ? 'Bấm nút "Thêm công việc" bên dưới để bắt đầu'
                                        : 'Thử chuyển sang bộ lọc khác',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                              itemCount: todos.length,
                              itemBuilder: (context, index) {
                                final todo = todos[index];
                                return TodoItem(
                                  key: ValueKey(todo.id),
                                  todo: todo,
                                  onCompleted: (value) =>
                                      _viewModel.setCompleted(todo.id, value),
                                  onEdit: () => _showTodoEditor(todo),
                                  onDelete: () =>
                                      _viewModel.deleteTodo(todo.id),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
