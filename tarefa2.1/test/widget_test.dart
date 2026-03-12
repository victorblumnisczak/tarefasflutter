// Test básico para o app TODO refatorado

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:todo_refatoracao_baguncado/core/presentation/app_root.dart';
import 'package:todo_refatoracao_baguncado/features/todos/presentation/viewmodels/todo_viewmodel.dart';
import 'package:todo_refatoracao_baguncado/features/todos/data/repositories/todo_repository_impl.dart';

void main() {
  testWidgets('App carrega corretamente', (WidgetTester tester) async {
    // Setup do repository e viewmodel
    final todoRepository = TodoRepositoryImpl();

    // Build do app
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TodoViewModel(todoRepository)),
        ],
        child: const AppRoot(),
      ),
    );

    // Verifica que o título da página existe
    expect(find.text('Todos'), findsOneWidget);
  });
}
