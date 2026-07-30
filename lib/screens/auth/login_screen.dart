import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../client/client_shell.dart';
import '../shared/api_settings_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _api = ApiService();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.login(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
      if (!mounted) return;
      if (result.success) {
        await context.read<SessionService>().login(
              email: _emailCtrl.text.trim(),
              role: result.role ?? 'user',
            );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const AppShell(),
          ),
        );
      } else {
        setState(() => _error = result.message);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Icon(Icons.local_pharmacy, size: 48, color: AppColors.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenue sur\nWellPharma',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, color: textMain),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous pour accéder à votre espace santé.',
                    style: TextStyle(color: textDim, fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: textDim),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock_outline, color: textDim),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(_error!, style: const TextStyle(color: AppColors.accentRed, fontSize: 13)),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Se connecter'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ApiSettingsScreen()),
                      ),
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: const Text('Configuration Serveur'),
                      style: TextButton.styleFrom(foregroundColor: textDim),
                    ),
                  ),
                  const Spacer(flex: 2),
                  Center(
                    child: Text(
                      '© 2026 WellPharma Madagascar',
                      style: TextStyle(color: textDim.withOpacity(0.5), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
