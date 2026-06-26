class Customer {
  final int? id;
  final String name;
  final String phone;
  final String notes;
  final DateTime createdAt;

  Customer({
    this.id,
    required this.name,
    this.phone = '',
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  static Customer fromMap(Map<String, dynamic> m) => Customer(
        id: m['id'],
        name: m['name'],
        phone: m['phone'] ?? '',
        notes: m['notes'] ?? '',
        createdAt: DateTime.parse(m['createdAt']),
      );
}
