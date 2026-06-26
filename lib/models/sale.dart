class Sale {
  final int? id;
  final String productName;
  final double price;
  final int quantity;
  final double total;
  final String customerName;
  final String customerPhone;
  final DateTime date;
  final String status; // paid, pending, cancelled

  Sale({
    this.id,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
    required this.customerName,
    this.customerPhone = '',
    required this.date,
    this.status = 'paid',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'total': total,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'date': date.toIso8601String(),
        'status': status,
      };

  static Sale fromMap(Map<String, dynamic> m) => Sale(
        id: m['id'],
        productName: m['productName'],
        price: m['price'],
        quantity: m['quantity'],
        total: m['total'],
        customerName: m['customerName'],
        customerPhone: m['customerPhone'] ?? '',
        date: DateTime.parse(m['date']),
        status: m['status'] ?? 'paid',
      );
}
