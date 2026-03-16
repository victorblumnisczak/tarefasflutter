import 'package:flutter/material.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/product_state.dart';

class ProductPage extends StatefulWidget {
  final ProductViewModel viewModel;

  const ProductPage({super.key, required this.viewModel});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          // Botão de filtro: mostrar apenas favoritos
          ValueListenableBuilder<ProductState>(
            valueListenable: widget.viewModel.state,
            builder: (context, state, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Contador de favoritos
                  if (state.favoriteCount > 0)
                    Chip(
                      label: Text(
                        '${state.favoriteCount} fav',
                        style: const TextStyle(fontSize: 12),
                      ),
                      avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
                      visualDensity: VisualDensity.compact,
                    ),
                  // Filtro de favoritos
                  IconButton(
                    icon: Icon(
                      state.showOnlyFavorites
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                      color: state.showOnlyFavorites ? Colors.amber : null,
                    ),
                    tooltip: state.showOnlyFavorites
                        ? 'Mostrar todos'
                        : 'Mostrar apenas favoritos',
                    onPressed: () =>
                        widget.viewModel.toggleShowOnlyFavorites(),
                  ),
                  // Botão de atualizar
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => widget.viewModel.loadProducts(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<ProductState>(
        valueListenable: widget.viewModel.state,
        builder: (context, state, _) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.loadProducts(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final displayProducts = state.filteredProducts;

          if (displayProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_border, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    state.showOnlyFavorites
                        ? 'Nenhum produto favorito ainda.'
                        : 'Nenhum produto encontrado.',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (state.showOnlyFavorites) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          widget.viewModel.toggleShowOnlyFavorites(),
                      child: const Text('Mostrar todos os produtos'),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: displayProducts.length,
            itemBuilder: (context, index) {
              final product = displayProducts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                // Destaque visual para produtos favoritados
                color: product.favorite
                    ? Colors.amber.withOpacity(0.08)
                    : null,
                child: ListTile(
                  leading: Image.network(
                    product.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  ),
                  title: Text(
                    product.title,
                    style: TextStyle(
                      fontWeight:
                          product.favorite ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: product.favorite ? Colors.amber[800] : null,
                      fontWeight:
                          product.favorite ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  // Botão de favorito
                  trailing: IconButton(
                    icon: Icon(
                      product.favorite ? Icons.star : Icons.star_border,
                      color: product.favorite ? Colors.amber : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () =>
                        widget.viewModel.toggleFavorite(product.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
