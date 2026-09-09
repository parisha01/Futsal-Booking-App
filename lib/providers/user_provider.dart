import 'package:flutter/foundation.dart';

/// Holds the current signed-in user's account details, a mock
/// "database" of registered accounts (email -> password/name/phone) so
/// login can be validated for real, and the set of favourited court IDs.
///
/// This is intentionally an in-memory store (front-end only, no backend)
/// but behaves like a real auth system: signing up registers an account;
/// logging in checks the email exists and the password matches, and
/// returns a specific error message otherwise.
class UserProvider extends ChangeNotifier {
  String name = 'Guest User';
  String email = '';
  String phone = '';
  bool hasAccount = false;
  bool rememberMe = false;
  String? avatarPath;

  void setAvatar(String path) {
    avatarPath = path;
    notifyListeners();
  }

  final Set<String> favoriteCourtIds = {};

  // email (lowercase) -> {password, name, phone}
  final Map<String, Map<String, String>> _registeredUsers = {};

  bool isFavorite(String courtId) => favoriteCourtIds.contains(courtId);

  void toggleFavorite(String courtId) {
    if (favoriteCourtIds.contains(courtId)) {
      favoriteCourtIds.remove(courtId);
    } else {
      favoriteCourtIds.add(courtId);
    }
    notifyListeners();
  }

  /// Registers a new account and signs the user in immediately.
  void signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    final key = email.trim().toLowerCase();
    _registeredUsers[key] = {'password': password, 'name': name, 'phone': phone};
    this.name = name;
    this.email = email.trim();
    this.phone = phone;
    hasAccount = true;
    notifyListeners();
  }

  /// Validates credentials against the registered account. Returns null
  /// on success, or a specific error message on failure (no account
  /// found vs. wrong password) so Login can surface accurate feedback.
  String? login({required String email, required String password, bool rememberMe = false}) {
    final key = email.trim().toLowerCase();
    final account = _registeredUsers[key];
    if (account == null) {
      return 'No account found for this email. Please sign up first.';
    }
    if (account['password'] != password) {
      return 'Incorrect email or password.';
    }
    name = account['name'] ?? name;
    phone = account['phone'] ?? '';
    this.email = email.trim();
    hasAccount = true;
    this.rememberMe = rememberMe;
    notifyListeners();
    return null;
  }

  void updateDetails({required String name, required String email, required String phone}) {
    this.name = name;
    this.email = email;
    this.phone = phone;
    final key = email.trim().toLowerCase();
    if (_registeredUsers.containsKey(key)) {
      _registeredUsers[key]!['name'] = name;
      _registeredUsers[key]!['phone'] = phone;
    }
    notifyListeners();
  }

  void logOut() {
    name = 'Guest User';
    email = '';
    phone = '';
    hasAccount = false;
    avatarPath = null;
    notifyListeners();
  }

  /// Removes the account entirely (both the display profile and the
  /// registered credentials), then logs out.
  void deleteAccount() {
    _registeredUsers.remove(email.trim().toLowerCase());
    favoriteCourtIds.clear();
    logOut();
  }
}
