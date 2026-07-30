import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../../services/session_service.dart';
import '../admin/dashboard_screen.dart';
import '../admin/stock_screen.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final session = context.watch<SessionService>();
    final isAdmin = session.role == UserRole.admin;

    final List<Widget> screens = [
      const HomeScreen(),
      const CartScreen(),
      if (isAdmin) const DashboardScreen(),
      if (isAdmin) const StockScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${cart.itemCount}'),
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.shopping_basket_outlined),
            ),
            label: 'Panier',
          ),
          if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Dashboard'),
          if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Stocks'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
