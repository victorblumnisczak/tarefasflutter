class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  final String description;
  final String category;
  final double rating;
  final int ratingCount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.description = '',
    this.category = '',
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingMap = json['rating'] as Map<String, dynamic>?;
    return Product(
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
      'title': title,
      'price': price,
      'description': description,
      'image': image,
      'category': category,
    };
  }
}
