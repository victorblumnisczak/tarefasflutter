import 'package:flutter/material.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loja de Produtos')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.shopping_bag),
          label: const Text('Ver Produtos'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductListScreen()),
          ),
        ),
      ),
    );
  }
}
