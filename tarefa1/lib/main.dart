import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/presentation/app_root.dart';
import 'features/todos/presentation/viewmodels/todo_viewmodel.dart';
import 'features/todos/data/repositories/todo_repository_impl.dart';

void main() {
  // Injeção de dependência: instancia o repository concreto
  final todoRepository = TodoRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
        // Passa o repository via construtor para o ViewModel
        ChangeNotifierProvider(create: (_) => TodoViewModel(todoRepository)),
      ],
      child: const AppRoot(),
    ),
  );
}
