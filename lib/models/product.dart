class Product {
  final String id;
  final String name;
  final List<String> colors;
  final Map<String, int> prices;
  final int sectionId;

  Product({
    required this.id,
    required this.name,
    required this.colors,
    required this.prices,
    this.sectionId = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colors': colors.join(','),
        'prices': prices.entries.map((e) => '${e.key}:${e.value}').join('||'),
        'sectionId': sectionId,
      };

  static Product fromMap(Map<String, dynamic> m) => Product(
        id: m['id'],
        name: m['name'],
        colors: (m['colors'] as String).split(','),
        prices: Map.fromEntries(
          (m['prices'] as String).split('||').map((e) {
            final parts = e.split(':');
            return MapEntry(parts[0], int.parse(parts[1]));
          }),
        ),
        sectionId: m['sectionId'] ?? 0,
      );
}
