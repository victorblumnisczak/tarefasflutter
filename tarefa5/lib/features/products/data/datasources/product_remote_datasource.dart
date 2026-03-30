import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductRemoteDatasource {
  final String baseUrl = 'https://fakestoreapi.com/products';

  Future<List<ProductModel>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((j) => ProductModel.fromJson(j)).toList();
    } else {
      throw Exception('Falha ao carregar produtos da API');
    }
  }

  /// Envia um novo produto para a API via POST.
  /// A FakeStoreAPI simula a criação e retorna o produto com id gerado.
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProductModel.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao cadastrar produto');
  }

  /// Atualiza um produto existente via PUT.
  /// O id vai na URL; o body contém os campos editáveis.
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return ProductModel.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao atualizar produto');
  }

  /// Remove um produto pelo id via DELETE.
  Future<bool> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Erro ao remover produto');
  }
}
