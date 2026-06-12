import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/favorites_controller.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _service = ProductService();

  List<Product> _all = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await _service.fetchProducts();
      if (!mounted) return;
      setState(() {
        _all = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar favoritos. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa o controller: ao desfavoritar, o filtro abaixo é recalculado
    // e o item some da tela imediatamente.
    final ids = context.watch<FavoritesController>().ids;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: _buildBody(ids),
    );
  }

  Widget _buildBody(Set<int> ids) {
    if (ids.isEmpty) {
      return const Center(child: Text('Nenhum produto favoritado ainda.'));
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final favorites = _all.where((p) => ids.contains(p.id)).toList();

    if (favorites.isEmpty) {
      return const Center(child: Text('Nenhum produto favoritado ainda.'));
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: product.id),
              ),
            );
          },
        );
      },
    );
  }
}
