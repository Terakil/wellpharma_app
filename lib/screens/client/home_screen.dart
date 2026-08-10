import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/product_card.dart';
import 'client_shell.dart';

class HomeScreen extends StatefulWidget {
  final bool focusSearch;
  const HomeScreen({super.key, this.focusSearch = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _searchFocus = FocusNode();
  String _query = '';
  String _selectedCategory = 'Tous';
  late Future<List<Product>> _future;

  final Map<String, IconData> _categories = {
    'Tous': Icons.all_inclusive,
    'Antibiotique': Icons.science_outlined,
    'Antitussif': Icons.air_outlined,
    'Antipaludique': Icons.bug_report_outlined,
    'Antalgique': Icons.personal_injury_outlined,
    'Vitamines': Icons.spa_outlined,
  };

  @override
  void initState() {
    super.initState();
    _future = _api.getStock();
    if (widget.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_searchFocus);
      });
    }
  }

  void _reload() => setState(() => _future = _api.getStock());

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 40),
                  const SizedBox(width: 8),
                  Image.asset('assets/images/logo2.png', height: 40),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Image.asset('assets/images/logo_ispm.png', height: 40),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => AppShell.of(context)?.setIndex(2),
                    child: Badge(
                      label: Text('${cart.itemCount}'),
                      isLabelVisible: cart.itemCount > 0,
                      child: const Icon(Icons.shopping_basket_outlined),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bienvenue sur WellPharma',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      'Trouvez vos médicaments et gérez votre santé facilement.',
                      style: TextStyle(color: textDim, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      focusNode: _searchFocus,
                      onChanged: (v) => setState(() => _query = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un médicament...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = _categories.keys.elementAt(i);
                          final icon = _categories[cat]!;
                          final isSelected = _selectedCategory == cat;
                          return ChoiceChip(
                            avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.primary),
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedCategory = cat);
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Nos Produits',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<Product>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: AppColors.accentRed)),
                    ),
                  );
                }
                final products = (snapshot.data ?? []).where((p) {
                  final matchesQuery = p.designation.toLowerCase().contains(_query) || p.reference.toLowerCase().contains(_query);
                  final matchesCat = _selectedCategory == 'Tous' || p.categorie.toLowerCase().contains(_selectedCategory.toLowerCase());
                  return matchesQuery && matchesCat;
                }).toList();

                if (products.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('Aucun produit trouvé', style: TextStyle(color: textDim)),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.70,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final p = products[i];
                        return ProductCard(
                          product: p,
                          onAdd: () {
                            context.read<CartService>().add(p.designation, p.categorie, p.prixUnitaire, p.needsPrescription, p.quantite);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${p.designation} ajouté au panier')),
                            );
                          },
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
