class CartItem {
  final String name;
  final String category;
  final num price;
  int quantity;

  CartItem({
    required this.name,
    required this.category,
    required this.price,
    this.quantity = 1,
  });

  num get total => price * quantity;
}
