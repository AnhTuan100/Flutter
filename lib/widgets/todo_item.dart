import 'package:flutter/material.dart';

import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.todo,
    required this.onCompleted,
    required this.onEdit,
    required this.onDelete,
  });

  final Todo todo;
  final ValueChanged<bool> onCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: todo.isCompleted ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onCompleted(!todo.isCompleted),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: todo.isCompleted,
                    semanticLabel: 'Hoàn thành ${todo.title}',
                    activeColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: const BorderSide(color: Color(0xFF94A3B8), width: 1.8),
                    onChanged: (value) => onCompleted(value ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: todo.isCompleted ? FontWeight.normal : FontWeight.w500,
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF94A3B8),
                      color: todo.isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Sửa công việc',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      color: const Color(0xFF64748B),
                      splashRadius: 20,
                    ),
                    IconButton(
                      tooltip: 'Xóa công việc',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: const Color(0xFFEF4444),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
