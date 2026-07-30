import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/session_service.dart';
import '../../services/theme_service.dart';
import 'help_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionService>();
    final theme = context.watch<ThemeService>();
    final isDark = theme.isDarkMode;
    
    final bgSide = isDark ? AppColors.bgSideDark : AppColors.bgSideLight;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgSide,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (session.email?.isNotEmpty == true ? session.email![0] : "U").toUpperCase(),
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    session.email?.split('@').first ?? "Utilisateur",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textMain),
                  ),
                  Text(
                    session.email ?? "",
                    style: TextStyle(color: textDim),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            _buildSettingsGroup(
              "Apparence",
              [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                  title: Text("Mode Sombre", style: TextStyle(color: textMain, fontWeight: FontWeight.w500)),
                  value: isDark,
                  onChanged: (bool value) => theme.toggleTheme(),
                ),
              ],
              isDark,
            ),

            _buildSettingsGroup(
              "Compte",
              [
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: "Mon Profil",
                  onTap: () {},
                  isDark: isDark,
                ),
                _buildSettingsTile(
                  icon: Icons.email_outlined,
                  title: "Email",
                  subtitle: session.email,
                  trailing: const SizedBox.shrink(),
                  isDark: isDark,
                ),
              ],
              isDark,
            ),
            
            _buildSettingsGroup(
              "Autres",
              [
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: "Aide & FAQ",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                  isDark: isDark,
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: "À propos",
                  onTap: () {},
                  isDark: isDark,
                ),
                _buildSettingsTile(
                  icon: Icons.logout,
                  title: "Se déconnecter",
                  titleColor: AppColors.accentRed,
                  iconColor: AppColors.accentRed,
                  onTap: () => session.logout(),
                  isDark: isDark,
                ),
              ],
              isDark,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(String label, List<Widget> children, bool isDark) {
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;
    final bgSide = isDark ? AppColors.bgSideDark : AppColors.bgSideLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 8),
          child: Text(label.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDim, letterSpacing: 1)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: bgSide,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
    required bool isDark,
  }) {
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(title, style: TextStyle(color: titleColor ?? textMain, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: textDim)) : null,
      trailing: trailing ?? Icon(Icons.chevron_right, size: 20, color: textDim),
      onTap: onTap,
    );
  }
}
