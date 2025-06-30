class RecursosVitais {
  final double energia;
  final double agua;
  final double saude;

  const RecursosVitais({
    required this.energia,
    required this.agua,
    required this.saude,
  });

  // Construtor com valores padrão
  RecursosVitais.inicial()
      : energia = 100.0,
        agua = 100.0,
        saude = 100.0;

  // Aplicar mudanças baseadas na resposta
  RecursosVitais aplicarMudanca(bool acertou) {
    if (acertou) {
      // Acerto: +5% em todos os recursos
      return RecursosVitais(
        energia: (energia + 5).clamp(0, 100),
        agua: (agua + 5).clamp(0, 100),
        saude: (saude + 5).clamp(0, 100),
      );
    } else {
      // Erro: -10% em todos os recursos
      return RecursosVitais(
        energia: (energia - 10).clamp(0, 100),
        agua: (agua - 10).clamp(0, 100),
        saude: (saude - 10).clamp(0, 100),
      );
    }
  }

  // 🔧 ADICIONADO: Método ajustar que estava faltando (usado pelo provider)
  RecursosVitais ajustar({
    required double energiaDelta,
    required double aguaDelta,
    required double saudeDelta,
  }) {
    return RecursosVitais(
      energia: (energia + energiaDelta).clamp(0, 100),
      agua: (agua + aguaDelta).clamp(0, 100),
      saude: (saude + saudeDelta).clamp(0, 100),
    );
  }

  // Verificar se está vivo
  bool get estaVivo => energia > 0 && agua > 0 && saude > 0;

  @override
  String toString() {
    return 'RecursosVitais(energia: $energia, agua: $agua, saude: $saude)';
  }

  // 🔧 ADICIONADO: Métodos úteis para conversão de dados
  Map<String, dynamic> toMap() {
    return {
      'energia': energia,
      'agua': agua,
      'saude': saude,
    };
  }

  factory RecursosVitais.fromMap(Map<String, dynamic> map) {
    return RecursosVitais(
      energia: (map['energia'] ?? 100.0).toDouble(),
      agua: (map['agua'] ?? 100.0).toDouble(),
      saude: (map['saude'] ?? 100.0).toDouble(),
    );
  }

  // 🔧 ADICIONADO: Operadores úteis para comparação
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecursosVitais &&
        other.energia == energia &&
        other.agua == agua &&
        other.saude == saude;
  }

  @override
  int get hashCode => energia.hashCode ^ agua.hashCode ^ saude.hashCode;
}
