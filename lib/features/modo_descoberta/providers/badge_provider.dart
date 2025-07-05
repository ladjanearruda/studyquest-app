// lib/features/modo_descoberta/providers/badge_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tipos de badges disponíveis no sistema
enum TipoBadge {
  autoconhecimento(
      'Autoconhecimento', '🧭', 'Descobriu seu nível de conhecimento'),
  persistencia('Persistência', '💪', 'Completou 5 trilhas consecutivas'),
  excelencia('Excelência', '🏆', 'Obteve 100% em uma trilha'),
  explorador('Explorador', '🗺️', 'Testou todos os cenários disponíveis'),
  mentor('Mentor', '👨‍🏫', 'Ajudou 10 colegas a estudar'),
  velocista('Velocista', '⚡', 'Completou trilha em tempo recorde'),
  estrategista('Estrategista', '🎯', 'Planejou 7 dias de estudos'),
  dedicado('Dedicado', '📚', 'Estudou 30 dias seguidos'),
  inovador('Inovador', '💡', 'Descobriu 3 métodos de estudo diferentes'),
  lider('Líder', '👑', 'Ficou no top 10 do ranking mensal');

  const TipoBadge(this.nome, this.emoji, this.descricao);
  final String nome;
  final String emoji;
  final String descricao;
}

/// Raridade das badges (afeta cor e valor)
enum RaridadeBadge {
  comum('Comum', '#95A5A6'), // Cinza
  raro('Raro', '#3498DB'), // Azul
  epico('Épico', '#9B59B6'), // Roxo
  lendario('Lendário', '#F39C12'), // Dourado
  mitico('Mítico', '#E74C3C'); // Vermelho

  const RaridadeBadge(this.nome, this.cor);
  final String nome;
  final String cor;
}

/// Modelo de uma badge conquistada
class Badge {
  final TipoBadge tipo;
  final RaridadeBadge raridade;
  final DateTime dataConquista;
  final Map<String, dynamic>? metadados; // Dados extras da conquista

  const Badge({
    required this.tipo,
    required this.raridade,
    required this.dataConquista,
    this.metadados,
  });

  /// Nome completo da badge
  String get nomeCompleto => '${tipo.emoji} ${tipo.nome}';

  /// Descrição com contexto
  String get descricaoCompleta {
    if (metadados != null && metadados!.isNotEmpty) {
      return '${tipo.descricao}\n${_formatarMetadados()}';
    }
    return tipo.descricao;
  }

  /// Formata metadados para exibição
  String _formatarMetadados() {
    if (metadados == null) return '';

    final buffer = StringBuffer();
    metadados!.forEach((key, value) {
      switch (key) {
        case 'acertos':
          buffer.write('$value/5 questões corretas');
          break;
        case 'tempo':
          buffer.write('Tempo: ${value}s');
          break;
        case 'nivel_detectado':
          buffer.write('Nível: $value');
          break;
        default:
          buffer.write('$key: $value');
      }
      buffer.write(' • ');
    });

    final result = buffer.toString();
    return result.endsWith(' • ')
        ? result.substring(0, result.length - 3)
        : result;
  }

  /// Data formatada
  String get dataFormatada {
    final agora = DateTime.now();
    final diferenca = agora.difference(dataConquista).inDays;

    if (diferenca == 0) return 'Hoje';
    if (diferenca == 1) return 'Ontem';
    if (diferenca < 7) return '$diferenca dias atrás';
    if (diferenca < 30) return '${(diferenca / 7).floor()} semanas atrás';
    return '${(diferenca / 30).floor()} meses atrás';
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo.toString(),
      'raridade': raridade.toString(),
      'data_conquista': dataConquista.toIso8601String(),
      'metadados': metadados,
    };
  }

  /// Cria a partir de JSON
  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      tipo: TipoBadge.values.firstWhere(
        (t) => t.toString() == json['tipo'],
      ),
      raridade: RaridadeBadge.values.firstWhere(
        (r) => r.toString() == json['raridade'],
      ),
      dataConquista: DateTime.parse(json['data_conquista']),
      metadados: json['metadados'],
    );
  }

  @override
  String toString() => nomeCompleto;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Badge &&
        other.tipo == tipo &&
        other.dataConquista == dataConquista;
  }

  @override
  int get hashCode => tipo.hashCode ^ dataConquista.hashCode;
}

/// Estado das badges do usuário
class BadgeState {
  final List<Badge> badgesConquistadas;
  final Badge? ultimaBadge; // Última badge conquistada (para animação)
  final bool mostrandoCelebracao; // Se deve mostrar animação de conquista

  const BadgeState({
    this.badgesConquistadas = const [],
    this.ultimaBadge,
    this.mostrandoCelebracao = false,
  });

  /// Verifica se uma badge específica foi conquistada
  bool hasBadge(TipoBadge tipo) {
    return badgesConquistadas.any((badge) => badge.tipo == tipo);
  }

  /// Total de badges conquistadas
  int get totalBadges => badgesConquistadas.length;

  /// Badges por raridade
  Map<RaridadeBadge, int> get badgesPorRaridade {
    final mapa = <RaridadeBadge, int>{};
    for (final raridade in RaridadeBadge.values) {
      mapa[raridade] = badgesConquistadas
          .where((badge) => badge.raridade == raridade)
          .length;
    }
    return mapa;
  }

  /// Próximas badges a conquistar
  List<TipoBadge> get proximasBadges {
    final conquistadas = badgesConquistadas.map((b) => b.tipo).toSet();
    return TipoBadge.values
        .where((tipo) => !conquistadas.contains(tipo))
        .toList();
  }

  /// Copia o estado com modificações
  BadgeState copyWith({
    List<Badge>? badgesConquistadas,
    Badge? ultimaBadge,
    bool? mostrandoCelebracao,
  }) {
    return BadgeState(
      badgesConquistadas: badgesConquistadas ?? this.badgesConquistadas,
      ultimaBadge: ultimaBadge ?? this.ultimaBadge,
      mostrandoCelebracao: mostrandoCelebracao ?? this.mostrandoCelebracao,
    );
  }

  @override
  String toString() => 'BadgeState(${badgesConquistadas.length} badges)';
}

/// Provider do estado das badges
final badgeProvider = StateNotifierProvider<BadgeNotifier, BadgeState>(
  (ref) => BadgeNotifier(),
);

/// Notifier que gerencia badges
class BadgeNotifier extends StateNotifier<BadgeState> {
  BadgeNotifier() : super(const BadgeState()) {
    // Inicializa badges salvas (futuro: carregar do storage)
    _carregarBadges();
  }

  /// Carrega badges do storage local (placeholder)
  void _carregarBadges() {
    // TODO: Implementar carregamento do SharedPreferences/Hive
    // Por enquanto, começar vazio
  }

  /// Conquista uma nova badge
  void conquistarBadge(TipoBadge tipo, {Map<String, dynamic>? metadados}) {
    // Verifica se já possui a badge
    if (state.hasBadge(tipo)) return;

    // Determina raridade baseada no tipo
    final raridade = _determinarRaridade(tipo);

    // Cria nova badge
    final novaBadge = Badge(
      tipo: tipo,
      raridade: raridade,
      dataConquista: DateTime.now(),
      metadados: metadados,
    );

    // Atualiza estado
    final novasBadges = [...state.badgesConquistadas, novaBadge];
    state = state.copyWith(
      badgesConquistadas: novasBadges,
      ultimaBadge: novaBadge,
      mostrandoCelebracao: true,
    );

    // Salva no storage
    _salvarBadges();
  }

// Determina raridade baseada no tipo de badge

  RaridadeBadge _determinarRaridade(TipoBadge tipo) {
    switch (tipo) {
      case TipoBadge.autoconhecimento:
      case TipoBadge.explorador:
        return RaridadeBadge.comum;

      case TipoBadge.persistencia:
      case TipoBadge.dedicado:
      case TipoBadge.estrategista:
        return RaridadeBadge.raro;

      case TipoBadge.excelencia:
      case TipoBadge.velocista:
      case TipoBadge.inovador:
        return RaridadeBadge.epico;

      case TipoBadge.mentor:
      case TipoBadge.lider:
        return RaridadeBadge.lendario;
      // ✅ Sem default - todos os casos cobertos
    }
  }

  /// Esconde a celebração da última badge
  void esconderCelebracao() {
    state = state.copyWith(mostrandoCelebracao: false);
  }

  /// Conquista badge do Modo Descoberta
  void conquistarAutoconhecimento({
    required int acertos,
    required int totalQuestoes,
    required Duration tempo,
    required String nivelDetectado,
  }) {
    conquistarBadge(
      TipoBadge.autoconhecimento,
      metadados: {
        'acertos': acertos,
        'total_questoes': totalQuestoes,
        'tempo': tempo.inSeconds,
        'nivel_detectado': nivelDetectado,
        'porcentagem': ((acertos / totalQuestoes) * 100).round(),
      },
    );
  }

  /// Remove uma badge (para debug/admin)
  void removerBadge(TipoBadge tipo) {
    final novasBadges =
        state.badgesConquistadas.where((badge) => badge.tipo != tipo).toList();

    state = state.copyWith(badgesConquistadas: novasBadges);
    _salvarBadges();
  }

  /// Reseta todas as badges
  void resetarBadges() {
    state = const BadgeState();
    _salvarBadges();
  }

  /// Salva badges no storage local (placeholder)
  void _salvarBadges() {
    // TODO: Implementar salvamento no SharedPreferences/Hive
    final json = state.badgesConquistadas.map((b) => b.toJson()).toList();
    // await storage.save('badges', json);

    // Debug: mostra quantas badges foram "salvas"
    print('🎯 Salvando ${json.length} badges no storage');
  }

  /// Método para debug - adiciona badges de exemplo
  void debugAdicionarBadgesExemplo() {
    conquistarAutoconhecimento(
      acertos: 4,
      totalQuestoes: 5,
      tempo: const Duration(minutes: 1, seconds: 45),
      nivelDetectado: 'Intermediário+',
    );

    // Simula outras badges com delay
    Future.delayed(const Duration(seconds: 2), () {
      conquistarBadge(TipoBadge.persistencia);
    });

    Future.delayed(const Duration(seconds: 4), () {
      conquistarBadge(TipoBadge.excelencia, metadados: {'trilha': 'Floresta'});
    });
  }
}

/// Provider para verificar se tem badge específica
final hasBadgeProvider = Provider.family<bool, TipoBadge>((ref, tipo) {
  return ref.watch(badgeProvider).hasBadge(tipo);
});

/// Provider para última badge conquistada
final ultimaBadgeProvider = Provider<Badge?>((ref) {
  return ref.watch(badgeProvider).ultimaBadge;
});

/// Provider para mostrar celebração
final mostrandoCelebracaoProvider = Provider<bool>((ref) {
  return ref.watch(badgeProvider).mostrandoCelebracao;
});

/// Provider para total de badges
final totalBadgesProvider = Provider<int>((ref) {
  return ref.watch(badgeProvider).totalBadges;
});

/// Provider para próximas badges
final proximasBadgesProvider = Provider<List<TipoBadge>>((ref) {
  return ref.watch(badgeProvider).proximasBadges;
});
