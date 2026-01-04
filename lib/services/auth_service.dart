// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  User? _user;
  bool _loggedIn = false;
  bool _initializing = false;
  String? _savedEmail;

  bool get loggedIn => _loggedIn;
  User? get user => _user;
  bool get initializing => _initializing;
  String? get savedEmail => _savedEmail;

  Future<void> init() async {
    _initializing = true;
    notifyListeners();
    try {
      final storedEmail = await _storage.read(key: 'auth_user_email');
      _savedEmail = storedEmail;
      
      // Token varsa kullanıcı bilgilerini API'den al
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        final profileResult = await ApiService.getUserProfile();
        if (profileResult['success']) {
          final userData = profileResult['data']['user'];
          _user = User(
            id: userData['id'],
            name: userData['name'],
            surname: userData['surname'],
            email: userData['email'],
            phone: userData['phone'] ?? '',
            password: '',
            avatar: userData['avatar'],
          );
          _loggedIn = true;
        } else {
          // Token geçersizse temizle
          await _storage.delete(key: 'auth_token');
          await _storage.delete(key: 'auth_user_email');
        }
      }
      
      _loggedIn = _user != null;
    } catch (e, st) {
      debugPrint('AuthService.init error: $e\n$st');
      _savedEmail = null;
      _loggedIn = false;
      _user = null;
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      debugPrint('🔄 API giriş işlemi başlatılıyor: $email');
      
      // Sadece API kullan
      final apiResult = await ApiService.login(
        email: email.trim(),
        password: password.trim(),
      );

      if (apiResult['success']) {
        final userData = apiResult['data']['user'];
        _user = User(
          id: userData['id'],
          name: userData['name'],
          surname: userData['surname'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          password: '', // Güvenlik için boş
          avatar: userData['avatar'],
        );
        _loggedIn = true;
        await _storage.write(key: 'auth_user_email', value: _user!.email);
        debugPrint('✅ MySQL API girişi başarılı: ${_user!.name}');
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ API giriş hatası: ${apiResult['error']}');
        return false;
      }
    } catch (e, st) {
      debugPrint('AuthService.loginWithEmail error: $e\n$st');
      return false;
    }
  }

  Future<bool> register(User u) async {
    try {
      debugPrint('🔄 API kayıt işlemi başlatılıyor: ${u.email}');
      
      // Sadece API kullan
      final apiResult = await ApiService.register(
        name: u.name,
        surname: u.surname,
        email: u.email.trim(),
        phone: u.phone,
        password: u.password,
      );

      debugPrint('📡 API yanıtı: ${apiResult['success']}');
      if (!apiResult['success']) {
        debugPrint('❌ API hatası: ${apiResult['error']}');
        return false;
      }

      final userData = apiResult['data']['user'];
      _user = User(
        id: userData['id'],
        name: userData['name'],
        surname: userData['surname'],
        email: userData['email'],
        phone: userData['phone'] ?? '',
        password: '', // Güvenlik için boş
        avatar: userData['avatar'],
      );
      _loggedIn = true;
      await _storage.write(key: 'auth_user_email', value: _user!.email);
      
      debugPrint('✅ MySQL API kaydı başarılı: ${_user!.name}');
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('AuthService.register error: $e\n$st');
      return false;
    }
  }

  /// Gerçek Google Sign-In (kullanmaya hazır, native config gerekir)
  Future<bool> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;
      
      final email = account.email;
      final displayName = account.displayName ?? '';
      
      // Google hesabı ile API'ye kayıt/giriş yap
      final parts = displayName.split(' ');
      final name = parts.isNotEmpty ? parts.first : 'GoogleUser';
      final surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      
      // Önce giriş dene
      final loginResult = await ApiService.login(email: email, password: 'google_oauth');
      
      if (loginResult['success']) {
        final userData = loginResult['data']['user'];
        _user = User(
          id: userData['id'],
          name: userData['name'],
          surname: userData['surname'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          password: '',
          avatar: userData['avatar'],
        );
      } else {
        // Giriş başarısızsa kayıt yap
        final registerResult = await ApiService.register(
          name: name,
          surname: surname,
          email: email,
          phone: '',
          password: 'google_oauth',
        );
        
        if (registerResult['success']) {
          final userData = registerResult['data']['user'];
          _user = User(
            id: userData['id'],
            name: userData['name'],
            surname: userData['surname'],
            email: userData['email'],
            phone: userData['phone'] ?? '',
            password: '',
            avatar: userData['avatar'],
          );
        } else {
          return false;
        }
      }
      
      _loggedIn = true;
      await _storage.write(key: 'auth_user_email', value: _user!.email);
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('AuthService.loginWithGoogle error: $e\n$st');
      return false;
    }
  }

  /// >>> GEÇİCİ / DEBUG: Google'a basınca hemen giriş yapsın diye mock method.
  /// Kullanımı: auth.loginWithGoogleMock()
  Future<bool> loginWithGoogleMock() async {
    try {
      // Demo mail - istersen burada farklı/uniq bir mail üretebilirsin
      const demoEmail = 'google_demo@example.com';
      
      // API ile giriş dene
      final loginResult = await ApiService.login(email: demoEmail, password: 'google_mock');
      
      if (loginResult['success']) {
        final userData = loginResult['data']['user'];
        _user = User(
          id: userData['id'],
          name: userData['name'],
          surname: userData['surname'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          password: '',
          avatar: userData['avatar'],
        );
      } else {
        // Giriş başarısızsa kayıt yap
        final registerResult = await ApiService.register(
          name: 'Google',
          surname: 'Demo',
          email: demoEmail,
          phone: '',
          password: 'google_mock',
        );
        
        if (registerResult['success']) {
          final userData = registerResult['data']['user'];
          _user = User(
            id: userData['id'],
            name: userData['name'],
            surname: userData['surname'],
            email: userData['email'],
            phone: userData['phone'] ?? '',
            password: '',
            avatar: userData['avatar'],
          );
        } else {
          return false;
        }
      }
      
      _loggedIn = true;
      await _storage.write(key: 'auth_user_email', value: _user!.email);
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('AuthService.loginWithGoogleMock error: $e\n$st');
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final email = credential.email ?? '';
      final userId = credential.userIdentifier ?? '';
      final fullName =
          ('${credential.givenName ?? ''} ${credential.familyName ?? ''}')
              .trim();

      final effectiveEmail = email.isNotEmpty
          ? email
          : (userId.isNotEmpty ? '$userId@apple.local' : '');

      if (effectiveEmail.isEmpty) {
        debugPrint('AuthService.loginWithApple: no email or userIdentifier.');
        return false;
      }

      // Apple hesabı ile API'ye kayıt/giriş yap
      final nameParts = fullName.isNotEmpty
          ? fullName.split(' ')
          : ['AppleUser'];
      final name = nameParts.isNotEmpty ? nameParts.first : 'AppleUser';
      final surname = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      // Önce giriş dene
      final loginResult = await ApiService.login(email: effectiveEmail, password: 'apple_oauth');
      
      if (loginResult['success']) {
        final userData = loginResult['data']['user'];
        _user = User(
          id: userData['id'],
          name: userData['name'],
          surname: userData['surname'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          password: '',
          avatar: userData['avatar'],
        );
      } else {
        // Giriş başarısızsa kayıt yap
        final registerResult = await ApiService.register(
          name: name,
          surname: surname,
          email: effectiveEmail,
          phone: '',
          password: 'apple_oauth',
        );
        
        if (registerResult['success']) {
          final userData = registerResult['data']['user'];
          _user = User(
            id: userData['id'],
            name: userData['name'],
            surname: userData['surname'],
            email: userData['email'],
            phone: userData['phone'] ?? '',
            password: '',
            avatar: userData['avatar'],
          );
        } else {
          return false;
        }
      }

      _loggedIn = true;
      await _storage.write(key: 'auth_user_email', value: _user!.email);
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('AuthService.loginWithApple error: $e\n$st');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _user = null;
      _loggedIn = false;
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'auth_user_email');
      await ApiService.removeToken(); // API token'ını da sil
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      notifyListeners();
    } catch (e, st) {
      debugPrint('AuthService.logout error: $e\n$st');
    }
  }

  // Kullanıcı bilgilerini yenile
  Future<void> refreshUser() async {
    try {
      final profileResult = await ApiService.getUserProfile();
      if (profileResult['success']) {
        final userData = profileResult['data']['user'];
        _user = User(
          id: userData['id'],
          name: userData['name'],
          surname: userData['surname'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          password: '',
          avatar: userData['avatar'],
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AuthService.refreshUser error: $e');
    }
  }
}
