import '../../domain/entities/product.dart';

class ProductState {
  final bool isLoading;
  final List<Product> products;
  final String? error;
  final bool showOnlyFavorites;

  const ProductState({
    this.isLoading = false,
    this.products = const [],
    this.error,
    this.showOnlyFavorites = false,
  });

  /// Retorna apenas os produtos favoritos
  List<Product> get favoriteProducts =>
      products.where((p) => p.favorite).toList();

  /// Contador de produtos favoritos
  int get favoriteCount => products.where((p) => p.favorite).length;

  /// Retorna a lista filtrada conforme o filtro ativo
  List<Product> get filteredProducts =>
      showOnlyFavorites ? favoriteProducts : products;

  ProductState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? error,
    bool? showOnlyFavorites,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }
}
