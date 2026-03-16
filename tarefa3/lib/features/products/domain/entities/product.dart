class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  bool favorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.favorite = false,
  });
}
