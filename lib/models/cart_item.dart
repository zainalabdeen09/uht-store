class CartItem {
  String productKey;
  String productName;
  String printing;
  int price;
  String color;
  String size;
  int quantity;

  CartItem({
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
        'id': null,
        'userId': 0,
        'productKey': productKey,
        'productName': productName,
        'printing': printing,
        'price': price,
        'color': color,
        'size': size,
        'quantity': quantity,
      };

  static CartItem fromMap(Map<String, dynamic> m) => CartItem(
        productKey: m['productKey'],
        productName: m['productName'],
        printing: m['printing'],
        price: m['price'],
        color: m['color'],
        size: m['size'] ?? 'L',
        quantity: m['quantity'] ?? 1,
      );
}
