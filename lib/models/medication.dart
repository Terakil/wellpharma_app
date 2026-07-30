class Medication {
  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  int stock;
  int sales;

  Medication({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.stock,
    this.sales = 0,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'].toString(),
      name: json['name'],
      category: json['category'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
      stock: int.parse(json['stock'].toString()),
      sales: int.tryParse(json['sales']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'image': image,
      'stock': stock,
      'sales': sales,
    };
  }
}
