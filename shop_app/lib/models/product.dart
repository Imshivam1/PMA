class Product {
  final int id;
  final String name;
  final String? brand;
  final int price;
  final int stock;

  Product({
    required this.id,
    required this.name,
    this.brand,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      name: json["name"],
      brand: json['brand'],
      price: json["price"],
      stock: json["stock"],
    );
  }
}