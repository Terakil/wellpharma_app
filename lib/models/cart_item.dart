class CartItem {
  final String name;
  final String category;
  final num price;
  int quantity;
  final bool needsPrescription;

  CartItem({
    required this.name,
    required this.category,
    required this.price,
    this.quantity = 1,
    this.needsPrescription = false,
  });

  num get total => price * quantity;
}
