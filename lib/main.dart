import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/api_config.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/client_shell.dart';
import 'services/cart_service.dart';
import 'services/session_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.instance.load();
  runApp(const WellPharmaApp());
}

class WellPharmaApp extends StatelessWidget {
  const WellPharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionService()..restore()),
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => ThemeService()..restore()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'WellPharma',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(Brightness.light),
            darkTheme: buildAppTheme(Brightness.dark),
            themeMode: theme.themeMode,
            home: const _RootGate(),
          );
        },
      ),
    );
  }
}

/// Redirige automatiquement vers le bon shell si une session existe déjà,
/// sinon affiche l'écran de connexion (reproduit la logique de
/// app.get('/') -> login.html côté serveur).
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionService>();
    if (!session.isLoggedIn) return const LoginScreen();
    return const AppShell();
  }
}
