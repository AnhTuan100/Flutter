import '../database/database_helper.dart';
import '../models/todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<Todo> insertTodo(String title);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(int id);
}

class SqliteTodoRepository implements TodoRepository {
  final DatabaseHelper _databaseHelper;

  SqliteTodoRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Todo>> getTodos() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('todos', orderBy: 'id DESC');
    return maps.map((map) => Todo.fromMap(map)).toList();
  }

  @override
  Future<Todo> insertTodo(String title) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('todos', {
      'title': title,
      'is_completed': 0,
    });
    return Todo(id: id, title: title, isCompleted: false);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final db = await _databaseHelper.database;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  @override
  Future<void> deleteTodo(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
