import 'package:flutter/foundation.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_state.dart';

class ProductViewModel {
  final ProductRepository repository;
  final ValueNotifier<ProductState> state = ValueNotifier(const ProductState());

  ProductViewModel(this.repository);

  Future<void> loadProducts() async {
    state.value = state.value.copyWith(isLoading: true);

    try {
      final products = await repository.getProducts();
      state.value = state.value.copyWith(
        isLoading: false,
        products: products,
      );
    } catch (e) {
      state.value = state.value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Alterna o estado de favorito de um produto pelo seu ID.
  /// A interface é atualizada automaticamente via ValueNotifier.
  void toggleFavorite(int productId) {
    final products = state.value.products;
    final index = products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    // Alterna o estado de favorito
    products[index].favorite = !products[index].favorite;

    // Cria uma nova lista para forçar a notificação de mudança
    state.value = state.value.copyWith(
      products: List.from(products),
    );
  }

  /// Alterna o filtro para mostrar apenas favoritos ou todos os produtos
  void toggleShowOnlyFavorites() {
    state.value = state.value.copyWith(
      showOnlyFavorites: !state.value.showOnlyFavorites,
    );
  }
}
