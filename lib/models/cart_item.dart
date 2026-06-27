class CartItem {
  final int? id;
  String productKey;
  String productName;
  String printing;
  int price;
  String color;
  String size;
  int quantity;

  CartItem({
    this.id,
    required this.productKey,
    required this.productName,
    required this.printing,
    required this.price,
    required this.color,
    this.size = 'L',
    this.quantity = 1,
  });

  int get total => price * quantity;

  Map<String, dynamic> toMap() => {
        'productKey': productKey,
        'productName': productName,
        'printing': printing,
        'price': price,
        'color': color,
        'size': size,
        'quantity': quantity,
      };

  static CartItem fromMap(Map<String, dynamic> m) => CartItem(
        id: m['id'] as int?,
        productKey: m['productKey'],
        productName: m['productName'],
        printing: m['printing'],
        price: m['price'] is int ? m['price'] as int : (m['price'] as num).toInt(),
        color: m['color'],
        size: m['size'] ?? 'L',
        quantity: m['quantity'] ?? 1,
      );
}
