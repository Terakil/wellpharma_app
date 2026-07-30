import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/formatters.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import 'add_product_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final _api = ApiService();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getStock();
  }

  void reload() => setState(() => _future = _api.getStock());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: RefreshIndicator(
        onRefresh: () async => reload(),
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState == ConnectionState.waiting;
            final products = snapshot.data ?? [];
            final totalRefs = products.length;
            final totalValue =
                products.fold<num>(0, (sum, p) => sum + (p.prixUnitaire * p.quantite));
            final alerts = products.where((p) => p.status != StockStatus.enStock).length;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (snapshot.hasError)
                  Card(
                    color: AppColors.accentRed.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text('${snapshot.error}',
                          style: const TextStyle(color: AppColors.accentRed, fontSize: 13)),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.medication_outlined,
                        label: 'Références',
                        value: loading ? '…' : '$totalRefs',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Valeur stock',
                        value: loading ? '…' : formatAr(totalValue),
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _StatCard(
                  icon: Icons.warning_amber_outlined,
                  label: 'Alertes stock (faible / rupture)',
                  value: loading ? '…' : '$alerts',
                  color: AppColors.accentRed,
                  wide: true,
                ),
                const SizedBox(height: 24),
                const Text('État des stocks (Aperçu)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                if (loading)
                  const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
                else if (products.isEmpty)
                  const SizedBox(height: 150, child: Center(child: Text("Aucun produit disponible")))
                else
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        barGroups: products.take(5).toList().asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.quantite.toDouble(),
                                color: e.value.quantite < 10 ? AppColors.accentRed : AppColors.primary,
                                width: 15,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              )
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < products.length && value.toInt() < 5) {
                                  final name = products[value.toInt()].designation;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      name.length > 5 ? name.substring(0, 5) : name,
                                      style: TextStyle(fontSize: 10, color: textDim),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                const Text('Actions rapides',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final added = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(builder: (_) => const AddProductScreen()),
                          );
                          if (added == true) reload();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Nouveau produit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Aperçu récent',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (!loading && products.isEmpty && !snapshot.hasError)
                  Text('Aucun produit en stock pour le moment.',
                      style: TextStyle(color: textDim)),
                ...products.take(5).map((p) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.medication_liquid, color: AppColors.primary),
                        title: Text(p.designation),
                        subtitle: Text('${p.categorie} · Réf. ${p.reference}'),
                        trailing: Text(formatAr(p.prixUnitaire)),
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool wide;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: textDim, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(fontSize: wide ? 20 : 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
