import 'package:flutter/material.dart';
import 'package:flutter_demo/database/database_helper.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.instance.close();
    final dbPath = await databaseFactory.getDatabasesPath();
    final filePath = p.join(dbPath, 'todos.db');
    await databaseFactory.deleteDatabase(filePath);
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  testWidgets('Adds, edits, completes, filters and deletes a todo', (
    tester,
  ) async {
    Future<void> settleAsync() async {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const MyApp());
    await settleAsync();
    expect(find.text('Chưa có công việc nào.'), findsOneWidget);

    await tester.tap(find.text('Thêm công việc'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Hãy nhập nội dung công việc.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Đọc sách');
    await tester.tap(find.text('Lưu'));
    await settleAsync();
    expect(find.text('Tổng: 1'), findsOneWidget);

    await tester.tap(find.byTooltip('Sửa công việc'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Đọc tài liệu');
    await tester.tap(find.text('Lưu'));
    await settleAsync();
    expect(find.text('Đọc tài liệu'), findsOneWidget);

    await tester.tap(find.text('Chưa xong'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await settleAsync();
    expect(find.text('Đọc tài liệu'), findsNothing);
    expect(find.text('Tổng: 1'), findsOneWidget);
    expect(find.text('Đã xong: 1'), findsOneWidget);
    expect(find.text('Chưa xong: 0'), findsOneWidget);

    await tester.tap(find.text('Đã xong'));
    await tester.pumpAndSettle();
    expect(find.text('Đọc tài liệu'), findsOneWidget);

    await tester.tap(find.byTooltip('Xóa công việc'));
    await settleAsync();
    expect(find.text('Tổng: 0'), findsOneWidget);
    expect(find.text('Đọc tài liệu'), findsNothing);
  });
}
