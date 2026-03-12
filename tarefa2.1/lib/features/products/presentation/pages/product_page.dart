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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.viewModel.loadProducts(),
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
              child: Text(state.error!),
            );
          }

          return ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ListTile(
                leading: Image.network(
                  product.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
                title: Text(product.title),
                subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
              );
            },
          );
        },
      ),
    );
  }
}
