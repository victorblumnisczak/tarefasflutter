import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:todo_refatoracao_baguncado/features/todos/presentation/viewmodels/todo_viewmodel.dart';
import 'package:todo_refatoracao_baguncado/features/todos/data/repositories/todo_repository_impl.dart';
import 'package:todo_refatoracao_baguncado/screens/home_screen.dart';

void main() {
  testWidgets('App carrega corretamente', (WidgetTester tester) async {
    final todoRepository = TodoRepositoryImpl();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TodoViewModel(todoRepository)),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Loja de Produtos'), findsOneWidget);
  });
}
