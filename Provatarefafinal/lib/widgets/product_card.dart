import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/favorites_controller.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFavorite =
        context.watch<FavoritesController>().isFavorite(product.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Image.network(
          product.thumbnail,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
        ),
        title: Text(product.title),
        subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              tooltip: isFavorite
                  ? 'Remover dos favoritos'
                  : 'Adicionar aos favoritos',
              onPressed: () =>
                  context.read<FavoritesController>().toggle(product.id),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
