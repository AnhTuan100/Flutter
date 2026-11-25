import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import '../repositories/todo_repository.dart';

enum TodoStatusFilter { all, active, completed }

class TodoViewModel extends ChangeNotifier {
  TodoViewModel({TodoRepository? repository})
      : _repository = repository ?? SqliteTodoRepository();

  final TodoRepository _repository;
  final List<Todo> _todos = [];
  TodoStatusFilter _filter = TodoStatusFilter.all;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  TodoStatusFilter get filter => _filter;
  int get totalCount => _todos.length;
  int get completedCount => _todos.where((todo) => todo.isCompleted).length;
  int get activeCount => totalCount - completedCount;

  List<Todo> get visibleTodos {
    final todos = switch (_filter) {
      TodoStatusFilter.all => _todos,
      TodoStatusFilter.active => _todos.where((todo) => !todo.isCompleted),
      TodoStatusFilter.completed => _todos.where((todo) => todo.isCompleted),
    };
    return List.unmodifiable(todos);
  }

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _repository.getTodos();
      _todos
        ..clear()
        ..addAll(items);
    } catch (e, st) {
      debugPrint('Error loading todos: $e\n$st');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(String title) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;

    final newTodo = await _repository.insertTodo(trimmedTitle);
    _todos.insert(0, newTodo);
    notifyListeners();
  }

  Future<void> editTodo(int id, String title) async {
    final trimmedTitle = title.trim();
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1 || trimmedTitle.isEmpty) return;

    final updatedTodo = _todos[index].copyWith(title: trimmedTitle);
    await _repository.updateTodo(updatedTodo);
    _todos[index] = updatedTodo;
    notifyListeners();
  }

  Future<void> setCompleted(int id, bool isCompleted) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1 || _todos[index].isCompleted == isCompleted) return;

    final updatedTodo = _todos[index].copyWith(isCompleted: isCompleted);
    await _repository.updateTodo(updatedTodo);
    _todos[index] = updatedTodo;
    notifyListeners();
  }

  Future<void> deleteTodo(int id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    await _repository.deleteTodo(id);
    _todos.removeAt(index);
    notifyListeners();
  }

  void setFilter(TodoStatusFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }
}
