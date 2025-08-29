// lib/core/services/firebase_config.dart
// Configuração Firebase simplificada para Sprint 6 MVP

class FirebaseConfig {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    try {
      // Para Sprint 6 MVP: simulamos a inicialização do Firebase
      // Mais tarde você configurará um projeto Firebase real

      await Future.delayed(const Duration(milliseconds: 500)); // Simular delay
      _isInitialized = true;

      print('✅ Firebase simulado inicializado (MVP mode)');
      print('📝 Nota: Para produção, configure um projeto Firebase real');
    } catch (e) {
      print('❌ Erro na inicialização simulada: $e');
      _isInitialized = false;
    }
  }

  static bool get isInitialized => _isInitialized;

  // Métodos helper para verificar status
  static bool get isOnline => true; // Simular sempre online
  static bool get hasConnection => true;
}
