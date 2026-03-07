import '../../core/network/http_client.dart';
import '../models/product_model.dart';

class ProductRemoteDatasource {
  final HttpClient client;

  ProductRemoteDatasource(this.client);

  Future<List<ProductModel>> getProducts() async {
    final response = await client.get(
      "https://fakestoreapi.com/products"
    );
    final List data = response.data;
    return data
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }
}
