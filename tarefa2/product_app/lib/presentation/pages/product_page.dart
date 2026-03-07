import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_viewmodel.dart';

class ProductPage extends StatelessWidget {
  final ProductViewModel viewModel;
  const ProductPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: viewModel.products,
        builder: (context, products, _) {
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(product.image),
                title: Text(product.title),
                subtitle: Text("\$${product.price}"),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.loadProducts,
        child: const Icon(Icons.download),
      ),
    );
  }
}
