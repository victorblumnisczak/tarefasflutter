import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/todos/presentation/pages/todos_page.dart';
import '../../features/products/presentation/pages/product_page.dart';
import '../../features/products/presentation/viewmodels/product_viewmodel.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arquitetura em Camadas',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
      routes: {
        '/todos': (context) => const TodosPage(),
        '/products': (context) {
          final viewModel = Provider.of<ProductViewModel>(context, listen: false);
          return ProductPage(viewModel: viewModel);
        },
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arquitetura em Camadas'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/todos'),
              child: const Text('Ver TODOs'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/products'),
              child: const Text('Ver Produtos'),
            ),
          ],
        ),
      ),
    );
  }
}
