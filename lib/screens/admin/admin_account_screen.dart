import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/session_service.dart';
import '../auth/login_screen.dart';
import '../shared/api_settings_screen.dart';
import '../shared/help_screen.dart';

class AdminAccountScreen extends StatelessWidget {
  const AdminAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Compte')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: const Icon(Icons.local_pharmacy, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(session.email ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          Center(
            child: Text('Chef Pharmacien', style: TextStyle(color: textDim, fontSize: 12)),
          ),
          const SizedBox(height: 28),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
              title: const Text('Configuration API'),
              trailing: Icon(Icons.chevron_right, color: textDim),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ApiSettingsScreen()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.help_outline, color: AppColors.primary),
              title: const Text('Aide & FAQ'),
              trailing: Icon(Icons.chevron_right, color: textDim),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              ),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              side: const BorderSide(color: AppColors.accentRed),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await context.read<SessionService>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
