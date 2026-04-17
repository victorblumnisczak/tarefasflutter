import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String _baseUrl = 'https://fakestoreapi.com/products';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((j) => Product.fromJson(j)).toList();
    }
    throw Exception('Falha ao carregar produtos');
  }

  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao cadastrar produto');
  }

  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception('Erro ao atualizar produto');
  }

  Future<bool> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Erro ao remover produto');
  }
}
