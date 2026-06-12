import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String _baseUrl = 'https://dummyjson.com/products';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['products'] as List<dynamic>;
      return list.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Falha ao carregar produtos');
  }

  Future<Product> fetchProductById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Erro ao carregar produto');
  }
}
