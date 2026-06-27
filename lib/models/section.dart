class Section {
  final int id;
  final String name;
  final String note;
  final int productCount;

  Section({
    required this.id,
    required this.name,
    this.note = '',
    this.productCount = 0,
  });
}
