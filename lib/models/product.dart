class Product {
  final int? id;
  final String name;
  final String category;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final String imageUrl;

  Product({
    this.id,
    required this.name,
    this.category = '',
    required this.buyPrice,
    required this.sellPrice,
    this.stock = 0,
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
        'stock': stock,
        'imageUrl': imageUrl,
      };

  static Product fromMap(Map<String, dynamic> m) => Product(
        id: m['id'],
        name: m['name'],
        category: m['category'] ?? '',
        buyPrice: (m['buyPrice'] ?? 0).toDouble(),
        sellPrice: (m['sellPrice'] ?? 0).toDouble(),
        stock: m['stock'] ?? 0,
        imageUrl: m['imageUrl'] ?? '',
      );
}
