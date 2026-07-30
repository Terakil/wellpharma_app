import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { admin, user }

/// Reproduit la logique de app.post('/api/login', ...) côté serveur :
/// - role "admin" -> tableau de bord pharmacien (ex "/other2")
/// - role "user"  -> interface client (ex "/acceuil")
class SessionService extends ChangeNotifier {
  static const _roleKey = 'wellpharma_role';
  static const _emailKey = 'wellpharma_email';

  UserRole? _role;
  String? _email;

  UserRole? get role => _role;
  String? get email => _email;
  bool get isLoggedIn => _role != null;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRole = prefs.getString(_roleKey);
    _email = prefs.getString(_emailKey);
    _role = storedRole == 'admin'
        ? UserRole.admin
        : storedRole == 'user'
            ? UserRole.user
            : null;
    notifyListeners();
  }

  Future<void> login({required String email, required String role}) async {
    _email = email;
    _role = role == 'admin' ? UserRole.admin : UserRole.user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
    await prefs.setString(_emailKey, email);
    notifyListeners();
  }

  Future<void> logout() async {
    _role = null;
    _email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    await prefs.remove(_emailKey);
    notifyListeners();
  }
}
