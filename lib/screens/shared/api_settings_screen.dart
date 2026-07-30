import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  late final TextEditingController _ctrl;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: ApiConfig.instance.baseUrl);
  }

  void _save() async {
    await ApiConfig.instance.setBaseUrl(_ctrl.text);
    setState(() => _saved = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL enregistrée avec succès.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuration API')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Adresse du serveur',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'L\'URL de base utilisée pour communiquer avec le backend (Express / MySQL).',
            style: TextStyle(color: textDim, fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              hintText: 'http://10.0.2.2:3000',
              labelText: 'URL de base',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Enregistrer les modifications'),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accentBlue, size: 20),
                    SizedBox(width: 8),
                    Text('Conseils de connexion',
                        style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                _TipItem(
                  title: 'Émulateur Android',
                  desc: 'Utilise http://10.0.2.2:3000',
                  isDark: isDark,
                  textMain: textMain,
                  textDim: textDim,
                ),
                _TipItem(
                  title: 'Simulateur iOS',
                  desc: 'Utilise http://localhost:3000',
                  isDark: isDark,
                  textMain: textMain,
                  textDim: textDim,
                ),
                _TipItem(
                  title: 'Appareil physique',
                  desc: 'Utilise l\'IP de ton PC (ex: http://192.168.1.50:3000)',
                  isDark: isDark,
                  textMain: textMain,
                  textDim: textDim,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String title;
  final String desc;
  final bool isDark;
  final Color textMain;
  final Color textDim;

  const _TipItem({
    required this.title,
    required this.desc,
    required this.isDark,
    required this.textMain,
    required this.textDim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textMain)),
          Text(desc, style: TextStyle(fontSize: 12, color: textDim)),
        ],
      ),
    );
  }
}
