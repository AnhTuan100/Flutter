import 'package:flutter_demo/database/database_helper.dart';
import 'package:flutter_demo/repositories/todo_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Sqlite repository CRUD', () async {
    final repo = SqliteTodoRepository();
    final item = await repo.insertTodo('Test 1');
    expect(item.id, isNotNull);
    expect(item.title, 'Test 1');

    final list = await repo.getTodos();
    expect(list.any((t) => t.id == item.id), isTrue);

    await repo.updateTodo(item.copyWith(isCompleted: true));
    final updatedList = await repo.getTodos();
    final updatedItem = updatedList.firstWhere((t) => t.id == item.id);
    expect(updatedItem.isCompleted, isTrue);

    await repo.deleteTodo(item.id);
    final finalList = await repo.getTodos();
    expect(finalList.any((t) => t.id == item.id), isFalse);

    await DatabaseHelper.instance.close();
  });
}
