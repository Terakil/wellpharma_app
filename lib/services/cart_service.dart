import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  num get total => _items.fold(0, (sum, i) => sum + i.total);

  bool get requiresPrescription => _items.any((item) => item.needsPrescription);

  void add(String name, String category, num price, bool needsPrescription, int maxStock) {
    final existing = _items.where((i) => i.name == name).toList();
    if (existing.isNotEmpty) {
      if (existing.first.quantity < maxStock) {
        existing.first.quantity++;
      }
    } else {
      if (maxStock > 0) {
        _items.add(CartItem(
          name: name, 
          category: category, 
          price: price, 
          needsPrescription: needsPrescription
        ));
      }
    }
    notifyListeners();
  }

  void increment(CartItem item, int maxStock) {
    if (item.quantity < maxStock) {
      item.quantity++;
      notifyListeners();
    }
  }

  void decrement(CartItem item) {
    item.quantity--;
    if (item.quantity <= 0) {
      _items.remove(item);
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
