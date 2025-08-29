// lib/services/firebase_rest_auth.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Auth implementado via REST API
/// Bypassa problemas JavaScript interop do Flutter Web
class FirebaseRestAuth {
  static const String _baseUrl = 'https://identitytoolkit.googleapis.com/v1';
  static const String _apiKey = 'AIzaSyBoO3KCt32eHzcT2SxlJLfbpVlk01ynlcs';

  /// Criar conta anônima (essencial para StudyQuest)
  static Future<FirebaseUser?> signInAnonymously() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts:signUp?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'returnSecureToken': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = FirebaseUser.fromJson(data);

        // Salvar localmente
        await _saveUserLocally(user);
        print('Firebase Auth anônimo criado: ${user.uid}');
        return user;
      } else {
        print('Erro status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erro Auth anônimo: $e');
    }
    return null;
  }

  /// Criar conta com email/senha
  static Future<FirebaseUser?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts:signUp?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = FirebaseUser.fromJson(data);
        await _saveUserLocally(user);
        return user;
      } else {
        print('Erro criar usuário: ${response.body}');
      }
    } catch (e) {
      print('Erro criar usuário: $e');
    }
    return null;
  }

  /// Login com email/senha
  static Future<FirebaseUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts:signInWithPassword?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = FirebaseUser.fromJson(data);
        await _saveUserLocally(user);
        return user;
      } else {
        print('Erro login: ${response.body}');
      }
    } catch (e) {
      print('Erro login: $e');
    }
    return null;
  }

  /// Verificar se usuário está logado
  static Future<FirebaseUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('firebase_user');

    if (userData != null) {
      try {
        final userMap = json.decode(userData);
        return FirebaseUser.fromJson(userMap);
      } catch (e) {
        print('Erro ao carregar usuário local: $e');
      }
    }
    return null;
  }

  /// Logout
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('firebase_user');
    print('Usuário deslogado');
  }

  /// Salvar usuário localmente
  static Future<void> _saveUserLocally(FirebaseUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(user.toJson());
    await prefs.setString('firebase_user', userData);
  }

  /// Inicializar usuário anônimo se necessário
  static Future<FirebaseUser> ensureUser() async {
    var user = await getCurrentUser();

    if (user == null) {
      user = await signInAnonymously();
      if (user == null) {
        throw Exception('Falha ao criar usuário Firebase');
      }
    }

    return user;
  }
}

/// Modelo de usuário Firebase
class FirebaseUser {
  final String uid;
  final String? email;
  final bool isAnonymous;
  final String? idToken;
  final String? refreshToken;

  FirebaseUser({
    required this.uid,
    this.email,
    this.isAnonymous = false,
    this.idToken,
    this.refreshToken,
  });

  factory FirebaseUser.fromJson(Map<String, dynamic> json) {
    return FirebaseUser(
      uid: json['localId'] ?? json['uid'] ?? '',
      email: json['email'],
      isAnonymous: json['email'] == null,
      idToken: json['idToken'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'isAnonymous': isAnonymous,
      'idToken': idToken,
      'refreshToken': refreshToken,
    };
  }

  @override
  String toString() {
    return 'FirebaseUser(uid: $uid, email: $email, isAnonymous: $isAnonymous)';
  }
}

/// Provider para gerenciar estado do usuário
final firebaseUserProvider =
    StateNotifierProvider<FirebaseUserNotifier, FirebaseUser?>((ref) {
  return FirebaseUserNotifier();
});

class FirebaseUserNotifier extends StateNotifier<FirebaseUser?> {
  FirebaseUserNotifier() : super(null) {
    _initUser();
  }

  Future<void> _initUser() async {
    final user = await FirebaseRestAuth.getCurrentUser();
    if (user != null) {
      state = user;
    } else {
      // Criar usuário anônimo para StudyQuest
      await signInAnonymously();
    }
  }

  Future<void> signInAnonymously() async {
    final user = await FirebaseRestAuth.signInAnonymously();
    if (user != null) {
      state = user;
    }
  }

  Future<void> createAccount(String email, String password) async {
    final user =
        await FirebaseRestAuth.createUserWithEmailAndPassword(email, password);
    if (user != null) {
      state = user;
    }
  }

  Future<void> signIn(String email, String password) async {
    final user =
        await FirebaseRestAuth.signInWithEmailAndPassword(email, password);
    if (user != null) {
      state = user;
    }
  }

  Future<void> signOut() async {
    await FirebaseRestAuth.signOut();
    state = null;
    // Criar novo usuário anônimo
    await signInAnonymously();
  }
}
