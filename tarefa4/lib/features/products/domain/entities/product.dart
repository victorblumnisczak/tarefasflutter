/// Entidade de domínio que representa um produto da FakeStoreAPI.
/// Contém apenas os dados relevantes para a lógica de negócio.
class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  final String description;
  final String category;
  final double rating;
  final int ratingCount;
  bool favorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.description = '',
    this.category = '',
    this.rating = 0.0,
    this.ratingCount = 0,
    this.favorite = false,
  });
}
