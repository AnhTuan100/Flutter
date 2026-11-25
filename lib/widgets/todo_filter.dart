import 'package:flutter/material.dart';

import '../viewmodels/todo_viewmodel.dart';

class TodoFilter extends StatelessWidget {
  const TodoFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TodoStatusFilter selected;
  final ValueChanged<TodoStatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    const filters = [
      (filter: TodoStatusFilter.all, label: 'Tất cả', icon: Icons.all_inbox_rounded),
      (filter: TodoStatusFilter.active, label: 'Chưa xong', icon: Icons.radio_button_unchecked_rounded),
      (filter: TodoStatusFilter.completed, label: 'Đã xong', icon: Icons.task_alt_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final item in filters) ...[
            FilterChip(
              avatar: Icon(
                item.icon,
                size: 16,
                color: selected == item.filter ? Theme.of(context).colorScheme.primary : const Color(0xFF64748B),
              ),
              label: Text(
                item.label,
                style: TextStyle(
                  fontWeight: selected == item.filter ? FontWeight.w600 : FontWeight.w500,
                  color: selected == item.filter ? Theme.of(context).colorScheme.primary : const Color(0xFF475569),
                ),
              ),
              selected: selected == item.filter,
              showCheckmark: false,
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
              side: BorderSide(
                color: selected == item.filter
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (_) => onChanged(item.filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
