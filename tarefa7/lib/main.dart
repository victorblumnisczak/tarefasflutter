import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/todos/presentation/viewmodels/todo_viewmodel.dart';
import 'features/todos/data/repositories/todo_repository_impl.dart';
import 'features/todos/presentation/pages/todos_page.dart';
import 'screens/home_screen.dart';

void main() {
  final todoRepository = TodoRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoViewModel(todoRepository)),
      ],
      child: MaterialApp(
        title: 'Loja de Produtos',
        theme: ThemeData(useMaterial3: true),
        home: const HomeScreen(),
        routes: {
          '/todos': (context) => const TodosPage(),
        },
      ),
    ),
  );
}
