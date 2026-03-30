import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<bool> deleteProduct(int id);
}
