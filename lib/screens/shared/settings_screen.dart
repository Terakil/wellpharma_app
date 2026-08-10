import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _profileImagePath;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
      _nameCtrl.text = prefs.getString('user_display_name') ?? '';
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', picked.path);
      setState(() => _profileImagePath = picked.path);
    }
  }

  Future<void> _saveProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_display_name', _nameCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour !')));
    }
  }

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
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            const SizedBox(width: 8),
            Image.asset('assets/images/logo2.png', height: 40),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('assets/images/logo_ispm.png', height: 40),
          ),
        ],
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
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                        child: _profileImagePath == null 
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: AppColors.accentBlue, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _nameCtrl.text.isNotEmpty ? _nameCtrl.text : (session.email?.split('@').first ?? "Utilisateur"),
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
              "Mon Profil",
              [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nom d\'affichage', hintText: 'Entrez votre nom'),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(onPressed: _saveProfileName, child: const Text('Enregistrer le nom')),
                      ),
                    ],
                  ),
                ),
              ],
              isDark,
            ),

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
              "Autres",
              [
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: "Aide & FAQ",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
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
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
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
