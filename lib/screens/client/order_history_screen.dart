import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/formatters.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with WidgetsBindingObserver {
  late Future<List<dynamic>> _future;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleRefresh();
    }
  }

  void _loadData() {
    final session = context.read<SessionService>();
    _future = _api.getOrderHistory(session.email ?? '');
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadData();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon historique d\'achats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: "Actualiser",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: AppColors.accentRed)),
                ),
              );
            }

            final orders = snapshot.data ?? [];

            if (orders.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 64, color: textDim.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text('Aucun achat enregistré.', style: TextStyle(color: textDim)),
                        const SizedBox(height: 8),
                        Text('Tirez pour rafraîchir', style: TextStyle(fontSize: 12, color: textDim.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final order = orders[i];
                final date = DateTime.parse(order['date']);
                final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(date);

                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: order['image_url'] != null 
                        ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(order['image_url'], fit: BoxFit.cover))
                        : const Icon(Icons.medication, color: AppColors.primary),
                    ),
                    title: Text(order['designation'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantité: ${order['quantite']}', style: TextStyle(fontSize: 12, color: textDim)),
                        Text(dateStr, style: TextStyle(fontSize: 11, color: textDim)),
                      ],
                    ),
                    trailing: Text(
                      formatAr(num.parse(order['prix_total'].toString())),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
