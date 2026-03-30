import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/presentation/app_root.dart';
import 'features/todos/presentation/viewmodels/todo_viewmodel.dart';
import 'features/todos/data/repositories/todo_repository_impl.dart';
import 'features/products/presentation/viewmodels/product_viewmodel.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/data/datasources/product_remote_datasource.dart';
import 'features/products/data/datasources/product_cache_datasource.dart';

void main() {
  // Injeção de dependência: instancia o repository concreto
  final todoRepository = TodoRepositoryImpl();

  // Injeção de dependência para Products
  final productRemoteDatasource = ProductRemoteDatasource();
  final productCacheDatasource = ProductCacheDatasource();
  final productRepository = ProductRepositoryImpl(
    productRemoteDatasource,
    productCacheDatasource,
  );
  final productViewModel = ProductViewModel(productRepository);

  runApp(
    MultiProvider(
      providers: [
        // Passa o repository via construtor para o ViewModel
        ChangeNotifierProvider(create: (_) => TodoViewModel(todoRepository)),
        // Provider para ProductViewModel
        Provider.value(value: productViewModel),
      ],
      child: const AppRoot(),
    ),
  );
}
