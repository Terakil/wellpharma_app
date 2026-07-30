import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

/// Panier local, équivalent du panier stocké en localStorage dans
/// public/js/app.js (ITEMS_KEY). Pas d'API commande côté serveur pour
/// l'instant : le panier reste local à l'appareil.
class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  num get total => _items.fold(0, (sum, i) => sum + i.total);

  void add(String name, String category, num price) {
    final existing = _items.where((i) => i.name == name).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(name: name, category: category, price: price));
    }
    notifyListeners();
  }

  void increment(CartItem item) {
    item.quantity++;
    notifyListeners();
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
