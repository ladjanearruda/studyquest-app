// lib/core/services/firebase_rest_auth.dart
// Sprint 8 - V2 com debug logs e correção de persistência

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Auth implementado via REST API
/// Bypassa problemas JavaScript interop do Flutter Web
class FirebaseRestAuth {
  static const String _baseUrl = 'https://identitytoolkit.googleapis.com/v1';
  static const String _apiKey = 'AIzaSyBoO3KCt32eHzcT2SxlJLfbpVlk01ynlcs';

  // Chaves do SharedPreferences
  static const String _keyUser = 'firebase_user';
  static const String _keyOnboarding = 'onboarding_complete';

  // ========================================
  // MÉTODOS DE AUTENTICAÇÃO
  // ========================================

  /// Criar conta com email/senha
  static Future<AuthResult> createUserWithEmailAndPassword(
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
        print('✅ Usuário criado: ${user.email}');
        return AuthResult.success(user);
      } else {
        final error = _parseError(response.body);
        print('❌ Erro criar usuário: $error');
        return AuthResult.failure(error);
      }
    } catch (e) {
      print('❌ Exceção criar usuário: $e');
      return AuthResult.failure('Erro de conexão. Verifique sua internet.');
    }
  }

  /// Login com email/senha
  static Future<AuthResult> signInWithEmailAndPassword(
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
        print('✅ Login realizado: ${user.email}');
        return AuthResult.success(user);
      } else {
        final error = _parseError(response.body);
        print('❌ Erro login: $error');
        return AuthResult.failure(error);
      }
    } catch (e) {
      print('❌ Exceção login: $e');
      return AuthResult.failure('Erro de conexão. Verifique sua internet.');
    }
  }

  /// Criar conta anônima (para usuários que não querem criar conta)
  static Future<AuthResult> signInAnonymously() async {
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
        await _saveUserLocally(user);
        print('✅ Usuário anônimo criado: ${user.uid}');
        return AuthResult.success(user);
      } else {
        final error = _parseError(response.body);
        print('❌ Erro criar anônimo: $error');
        return AuthResult.failure(error);
      }
    } catch (e) {
      print('❌ Exceção criar anônimo: $e');
      return AuthResult.failure('Erro de conexão. Verifique sua internet.');
    }
  }

  /// Enviar email de recuperação de senha
  static Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts:sendOobCode?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'requestType': 'PASSWORD_RESET',
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Email de recuperação enviado para: $email');
        return AuthResult.success(null);
      } else {
        final error = _parseError(response.body);
        print('❌ Erro enviar email: $error');
        return AuthResult.failure(error);
      }
    } catch (e) {
      print('❌ Exceção enviar email: $e');
      return AuthResult.failure('Erro de conexão. Verifique sua internet.');
    }
  }

  /// Verificar se usuário está logado
  static Future<FirebaseUser?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_keyUser);

      print('🔍 getCurrentUser - userData exists: ${userData != null}');

      if (userData != null) {
        final userMap = json.decode(userData);
        final user = FirebaseUser.fromJson(userMap);
        print('🔍 getCurrentUser - user: ${user.email ?? user.uid}');
        return user;
      }
    } catch (e) {
      print('❌ Erro ao carregar usuário local: $e');
    }
    return null;
  }

  /// Retorna headers HTTP com Content-Type e Authorization (idToken renovado se necessário)
  /// Use em todas as chamadas REST ao Firestore para respeitar Security Rules.
  static Future<Map<String, String>> getAuthHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    try {
      var user = await getCurrentUser();
      if (user != null) {
        // Renovar token se expirado ou prestes a expirar
        if (user.isTokenExpired && user.refreshToken != null) {
          print('🔄 Token expirado, renovando...');
          user = await _refreshToken(user) ?? user;
        }
        if (user.idToken != null) {
          headers['Authorization'] = 'Bearer ${user.idToken!}';
        }
      }
    } catch (_) {}
    return headers;
  }

  /// Renovar idToken usando o refreshToken
  static Future<FirebaseUser?> _refreshToken(FirebaseUser user) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://securetoken.googleapis.com/v1/token?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grant_type': 'refresh_token',
          'refresh_token': user.refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final expiresIn = int.tryParse(data['expires_in'].toString()) ?? 3600;
        final refreshed = FirebaseUser(
          uid: user.uid,
          email: user.email,
          isAnonymous: user.isAnonymous,
          idToken: data['id_token'],
          refreshToken: data['refresh_token'],
          tokenExpiry: DateTime.now().add(Duration(seconds: expiresIn)),
        );
        await _saveUserLocally(refreshed);
        print('✅ Token renovado com sucesso');
        return refreshed;
      } else {
        print('❌ Falha ao renovar token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exceção ao renovar token: $e');
    }
    return null;
  }

  /// Logout
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    // NÃO remove onboarding_complete para manter o estado
    print('✅ Usuário deslogado (onboarding mantido)');
  }

  // ========================================
  // MÉTODOS DE ONBOARDING
  // ========================================

  /// Verificar se onboarding foi completado
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_keyOnboarding) ?? false;
      print('🔍 hasCompletedOnboarding: $completed');

      // Debug: listar todas as chaves
      final keys = prefs.getKeys();
      print('🔍 Todas as chaves no SharedPreferences: $keys');

      return completed;
    } catch (e) {
      print('❌ Erro verificar onboarding: $e');
      return false;
    }
  }

  /// Marcar onboarding como completo
  static Future<void> setOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboarding, true);

      // Verificar se salvou
      final verificar = prefs.getBool(_keyOnboarding);
      print('✅ Onboarding marcado como completo!');
      print('🔍 Verificação imediata: onboarding_complete = $verificar');

      // Debug: listar todas as chaves
      final keys = prefs.getKeys();
      print('🔍 Todas as chaves após salvar: $keys');
    } catch (e) {
      print('❌ Erro ao salvar onboarding: $e');
    }
  }

  /// Resetar onboarding (para testes ou refazer)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboarding);
    print('🔄 Onboarding resetado');
  }

  // ========================================
  // MÉTODOS AUXILIARES
  // ========================================

  /// Salvar usuário localmente
  static Future<void> _saveUserLocally(FirebaseUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(user.toJson());
      await prefs.setString(_keyUser, userData);
      print('💾 Usuário salvo localmente: ${user.email ?? user.uid}');
    } catch (e) {
      print('❌ Erro ao salvar usuário: $e');
    }
  }

  /// Parser de erros do Firebase
  static String _parseError(String responseBody) {
    try {
      final data = json.decode(responseBody);
      final errorCode = data['error']?['message'] ?? 'UNKNOWN_ERROR';

      switch (errorCode) {
        case 'EMAIL_EXISTS':
          return 'Este email já está cadastrado';
        case 'INVALID_EMAIL':
          return 'Email inválido';
        case 'WEAK_PASSWORD':
          return 'Senha muito fraca (mínimo 6 caracteres)';
        case 'EMAIL_NOT_FOUND':
          return 'Email não encontrado';
        case 'INVALID_PASSWORD':
          return 'Senha incorreta';
        case 'USER_DISABLED':
          return 'Esta conta foi desativada';
        case 'TOO_MANY_ATTEMPTS_TRY_LATER':
          return 'Muitas tentativas. Tente novamente mais tarde';
        case 'INVALID_LOGIN_CREDENTIALS':
          return 'Email ou senha incorretos';
        default:
          return 'Erro: $errorCode';
      }
    } catch (e) {
      return 'Erro desconhecido';
    }
  }

  /// Inicializar usuário (anônimo se necessário)
  static Future<FirebaseUser> ensureUser() async {
    var user = await getCurrentUser();

    if (user == null) {
      final result = await signInAnonymously();
      if (result.isSuccess && result.user != null) {
        return result.user!;
      }
      throw Exception('Falha ao criar usuário Firebase');
    }

    return user;
  }
}

// ========================================
// MODELOS
// ========================================

/// Resultado de operação de autenticação
class AuthResult {
  final bool isSuccess;
  final FirebaseUser? user;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(FirebaseUser? user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}

/// Modelo de usuário Firebase
class FirebaseUser {
  final String uid;
  final String? email;
  final bool isAnonymous;
  final String? idToken;
  final String? refreshToken;
  final DateTime? tokenExpiry;

  FirebaseUser({
    required this.uid,
    this.email,
    this.isAnonymous = false,
    this.idToken,
    this.refreshToken,
    this.tokenExpiry,
  });

  /// Token está expirado ou expira nos próximos 5 minutos
  bool get isTokenExpired {
    if (tokenExpiry == null) return true;
    return DateTime.now()
        .isAfter(tokenExpiry!.subtract(const Duration(minutes: 5)));
  }

  factory FirebaseUser.fromJson(Map<String, dynamic> json) {
    DateTime? expiry;
    if (json['expiresIn'] != null) {
      final seconds = int.tryParse(json['expiresIn'].toString()) ?? 3600;
      expiry = DateTime.now().add(Duration(seconds: seconds));
    } else if (json['tokenExpiry'] != null) {
      expiry = DateTime.tryParse(json['tokenExpiry'].toString());
    }
    return FirebaseUser(
      uid: json['localId'] ?? json['uid'] ?? '',
      email: json['email'],
      isAnonymous: json['email'] == null,
      idToken: json['idToken'],
      refreshToken: json['refreshToken'],
      tokenExpiry: expiry,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'localId': uid,
      'email': email,
      'isAnonymous': isAnonymous,
      'idToken': idToken,
      'refreshToken': refreshToken,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'FirebaseUser(uid: $uid, email: $email, isAnonymous: $isAnonymous)';
  }
}

// ========================================
// PROVIDERS (RIVERPOD)
// ========================================

/// Estado da autenticação
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Estado completo de autenticação
class AuthState {
  final AuthStatus status;
  final FirebaseUser? user;
  final String? errorMessage;
  final bool hasCompletedOnboarding;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.hasCompletedOnboarding = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    FirebaseUser? user,
    String? errorMessage,
    bool? hasCompletedOnboarding,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Provider para gerenciar estado do usuário
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _initUser();
  }

  Future<void> _initUser() async {
    state = state.copyWith(status: AuthStatus.loading);
    print('🔄 AuthNotifier._initUser() iniciando...');

    try {
      final user = await FirebaseRestAuth.getCurrentUser();
      final hasOnboarding = await FirebaseRestAuth.hasCompletedOnboarding();

      print('🔍 _initUser - user: ${user?.email ?? user?.uid ?? "null"}');
      print('🔍 _initUser - hasOnboarding: $hasOnboarding');

      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          hasCompletedOnboarding: hasOnboarding,
        );
        print('✅ _initUser - Autenticado, onboarding: $hasOnboarding');
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        print('⚠️ _initUser - Não autenticado');
      }
    } catch (e) {
      print('❌ _initUser erro: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Erro ao verificar autenticação',
      );
    }
  }

  /// Criar conta com email/senha
  Future<bool> createAccount(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    print('🔄 createAccount: $email');

    final result =
        await FirebaseRestAuth.createUserWithEmailAndPassword(email, password);

    if (result.isSuccess && result.user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        hasCompletedOnboarding: false,
      );
      print('✅ createAccount - Conta criada com sucesso');
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.errorMessage,
      );
      print('❌ createAccount - Falha: ${result.errorMessage}');
      return false;
    }
  }

  /// Login com email/senha
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    print('🔄 signIn: $email');

    final result =
        await FirebaseRestAuth.signInWithEmailAndPassword(email, password);

    if (result.isSuccess && result.user != null) {
      final hasOnboarding = await FirebaseRestAuth.hasCompletedOnboarding();
      print('🔍 signIn - hasOnboarding após login: $hasOnboarding');

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        hasCompletedOnboarding: hasOnboarding,
      );
      print('✅ signIn - Login OK, onboarding: $hasOnboarding');
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.errorMessage,
      );
      print('❌ signIn - Falha: ${result.errorMessage}');
      return false;
    }
  }

  /// Login anônimo (continuar sem conta)
  Future<bool> signInAnonymously() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    print('🔄 signInAnonymously');

    final result = await FirebaseRestAuth.signInAnonymously();

    if (result.isSuccess && result.user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        hasCompletedOnboarding: false,
      );
      print('✅ signInAnonymously - OK');
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.errorMessage,
      );
      print('❌ signInAnonymously - Falha: ${result.errorMessage}');
      return false;
    }
  }

  /// Enviar email de recuperação
  Future<bool> sendPasswordReset(String email) async {
    print('🔄 sendPasswordReset: $email');
    final result = await FirebaseRestAuth.sendPasswordResetEmail(email);
    return result.isSuccess;
  }

  /// Marcar onboarding como completo
  Future<void> completeOnboarding() async {
    print('🔄 completeOnboarding chamado');
    await FirebaseRestAuth.setOnboardingComplete();
    state = state.copyWith(hasCompletedOnboarding: true);
    print(
        '✅ completeOnboarding - Estado atualizado: ${state.hasCompletedOnboarding}');
  }

  /// Logout
  Future<void> signOut() async {
    print('🔄 signOut');
    await FirebaseRestAuth.signOut();
    state = AuthState(status: AuthStatus.unauthenticated);
    print('✅ signOut - Deslogado');
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// ========================================
// PROVIDER LEGADO (COMPATIBILIDADE)
// ========================================

/// Provider legado para compatibilidade com código existente
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
    }
  }

  Future<void> signInAnonymously() async {
    final result = await FirebaseRestAuth.signInAnonymously();
    if (result.isSuccess && result.user != null) {
      state = result.user;
    }
  }

  Future<void> createAccount(String email, String password) async {
    final result =
        await FirebaseRestAuth.createUserWithEmailAndPassword(email, password);
    if (result.isSuccess && result.user != null) {
      state = result.user;
    }
  }

  Future<void> signIn(String email, String password) async {
    final result =
        await FirebaseRestAuth.signInWithEmailAndPassword(email, password);
    if (result.isSuccess && result.user != null) {
      state = result.user;
    }
  }

  Future<void> signOut() async {
    await FirebaseRestAuth.signOut();
    state = null;
  }
}
