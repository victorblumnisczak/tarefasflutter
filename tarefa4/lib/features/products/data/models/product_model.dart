import '../../domain/entities/product.dart';

/// DTO (Data Transfer Object) responsável por mapear o JSON da FakeStoreAPI
/// para objetos Dart e converter para a Entity de domínio.
class ProductModel {
  final int id;
  final String title;
  final double price;
  final String image;
  final String description;
  final String category;
  final double rating;
  final int ratingCount;

  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.description = '',
    this.category = '',
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  /// Cria um ProductModel a partir do JSON retornado pela API.
  /// O campo "rating" na API é um objeto: {"rate": 3.9, "count": 120}
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final ratingMap = json['rating'] as Map<String, dynamic>?;

    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      rating: ratingMap != null ? (ratingMap['rate'] as num).toDouble() : 0.0,
      ratingCount: ratingMap != null ? ratingMap['count'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'image': image,
      'description': description,
      'category': category,
      'rating': {'rate': rating, 'count': ratingCount},
    };
  }

  /// Converte o Model (camada de dados) para a Entity (camada de domínio)
  Product toEntity() {
    return Product(
      id: id,
      title: title,
      price: price,
      image: image,
      description: description,
      category: category,
      rating: rating,
      ratingCount: ratingCount,
    );
  }
}
