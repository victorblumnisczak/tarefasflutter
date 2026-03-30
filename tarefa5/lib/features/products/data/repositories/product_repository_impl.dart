import '../../../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_cache_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remote;
  final ProductCacheDatasource cache;

  ProductRepositoryImpl(this.remote, this.cache);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final models = await remote.getProducts();
      cache.save(models);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      final cached = cache.get();
      if (cached != null) {
        return cached.map((m) => m.toEntity()).toList();
      }
      throw Failure("Não foi possível carregar os produtos");
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    final model = ProductModel.fromEntity(product);
    final result = await remote.createProduct(model);
    return result.toEntity();
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final model = ProductModel.fromEntity(product);
    final result = await remote.updateProduct(model);
    return result.toEntity();
  }

  @override
  Future<bool> deleteProduct(int id) async {
    return remote.deleteProduct(id);
  }
}
