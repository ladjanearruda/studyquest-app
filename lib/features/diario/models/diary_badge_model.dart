// lib/features/diario/models/diary_badge_model.dart
// ✅ V9.4 - Sprint 9 Fase 3: Badges com XP Reduzido + Categorias Corretas
// 📅 Atualizado: 27/02/2026
// 🎯 XP balanceado conforme decisão de negócio

/// Categoria da badge
enum BadgeCategory {
  anotacao, // Relacionadas a fazer anotações
  transformacao, // Relacionadas a transformar erros (revanche com anotação)
  consistencia, // Relacionadas a uso contínuo
  emocao, // Relacionadas ao bem-estar
  revisao, // Relacionadas a revisões (futuro: Spaced Repetition)
  especial, // Badges especiais/supremas
}

/// Raridade da badge (afeta visual e XP)
enum BadgeRarity {
  comum, // 🟢 Fácil de conseguir
  incomum, // 🔵 Requer esforço
  raro, // 🟣 Desafiador
  epico, // 🟠 Muito difícil
  lendario, // 🟡 Extremamente raro
}

/// Definição de uma badge
class DiaryBadge {
  final String id;
  final String emoji;
  final String nome;
  final String descricao;
  final String hint; // Dica de como desbloquear
  final BadgeCategory categoria;
  final BadgeRarity raridade;
  final int xpRecompensa;
  final Map<String, dynamic> criterios; // Critérios para desbloquear

  const DiaryBadge({
    required this.id,
    required this.emoji,
    required this.nome,
    required this.descricao,
    required this.hint,
    required this.categoria,
    required this.raridade,
    required this.xpRecompensa,
    required this.criterios,
  });

  /// Cor baseada na raridade
  String get corHex {
    switch (raridade) {
      case BadgeRarity.comum:
        return '#4CAF50'; // Verde
      case BadgeRarity.incomum:
        return '#2196F3'; // Azul
      case BadgeRarity.raro:
        return '#9C27B0'; // Roxo
      case BadgeRarity.epico:
        return '#FF9800'; // Laranja
      case BadgeRarity.lendario:
        return '#FFD700'; // Dourado
    }
  }

  /// Nome da raridade em português
  String get raridadeNome {
    switch (raridade) {
      case BadgeRarity.comum:
        return 'Comum';
      case BadgeRarity.incomum:
        return 'Incomum';
      case BadgeRarity.raro:
        return 'Raro';
      case BadgeRarity.epico:
        return 'Épico';
      case BadgeRarity.lendario:
        return 'Lendário';
    }
  }
}

/// Badge desbloqueada pelo usuário
class UnlockedBadge {
  final String badgeId;
  final String odId;
  final DateTime unlockedAt;
  final int xpEarned;

  UnlockedBadge({
    required this.badgeId,
    required this.odId,
    required this.unlockedAt,
    required this.xpEarned,
  });

  Map<String, dynamic> toMap() {
    return {
      'badge_id': badgeId,
      'user_id': odId,
      'unlocked_at': unlockedAt.toIso8601String(),
      'xp_earned': xpEarned,
    };
  }

  factory UnlockedBadge.fromMap(Map<String, dynamic> map) {
    return UnlockedBadge(
      badgeId: map['badge_id'] ?? '',
      odId: map['user_id'] ?? '',
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'])
          : DateTime.now(),
      xpEarned: map['xp_earned'] ?? 0,
    );
  }
}

/// Catálogo de todas as badges disponíveis
/// ✅ V9.4: XP REDUZIDO conforme decisão de negócio
class DiaryBadgeCatalog {
  static const List<DiaryBadge> todas = [
    // ═══════════════════════════════════════════
    // 🌱 BADGES DE ANOTAÇÃO
    // Onde aparecem: Modal de Anotação
    // ═══════════════════════════════════════════
    DiaryBadge(
      id: 'primeira_anotacao',
      emoji: '🌱',
      nome: 'Primeira Semente',
      descricao: 'Fez sua primeira anotação no Diário',
      hint: 'Erre uma questão e anote sua reflexão',
      categoria: BadgeCategory.anotacao,
      raridade: BadgeRarity.comum,
      xpRecompensa: 50, // ✅ Mantido
      criterios: {'total_anotacoes': 1},
    ),
    DiaryBadge(
      id: 'estudioso',
      emoji: '📚',
      nome: 'Estudioso',
      descricao: 'Fez 10 anotações reflexivas',
      hint: 'Continue anotando seus erros e aprendizados',
      categoria: BadgeCategory.anotacao,
      raridade: BadgeRarity.comum,
      xpRecompensa: 75, // ✅ Reduzido de 100
      criterios: {'total_anotacoes': 10},
    ),
    DiaryBadge(
      id: 'cientista',
      emoji: '🔬',
      nome: 'Cientista',
      descricao: 'Fez 50 anotações no Diário',
      hint: 'Sua dedicação está rendendo frutos!',
      categoria: BadgeCategory.anotacao,
      raridade: BadgeRarity.incomum,
      xpRecompensa: 100, // ✅ Reduzido de 200
      criterios: {'total_anotacoes': 50},
    ),
    DiaryBadge(
      id: 'genio',
      emoji: '🧠',
      nome: 'Gênio',
      descricao: 'Fez 100 anotações reflexivas',
      hint: 'Você é um mestre da reflexão!',
      categoria: BadgeCategory.anotacao,
      raridade: BadgeRarity.raro,
      xpRecompensa: 150, // ✅ Reduzido de 500
      criterios: {'total_anotacoes': 100},
    ),

    // ═══════════════════════════════════════════
    // 🔄 BADGES DE TRANSFORMAÇÃO
    // Onde aparecem: Modal de Feedback da Revanche
    // Critério: Acertar questão que tinha ANOTAÇÃO
    // ═══════════════════════════════════════════
    DiaryBadge(
      id: 'transformador',
      emoji: '🔄',
      nome: 'Transformador',
      descricao: 'Transformou seu primeiro erro em acerto',
      hint: 'Acerte uma questão que você tinha errado e anotado',
      categoria: BadgeCategory.transformacao,
      raridade: BadgeRarity.comum,
      xpRecompensa: 50, // ✅ Reduzido de 150
      criterios: {'total_transformacoes': 1},
    ),
    DiaryBadge(
      id: 'metamorfose',
      emoji: '⚡',
      nome: 'Metamorfose',
      descricao: 'Transformou 10 erros em acertos',
      hint: 'Continue transformando seus erros!',
      categoria: BadgeCategory.transformacao,
      raridade: BadgeRarity.incomum,
      xpRecompensa: 75, // ✅ Reduzido de 200
      criterios: {'total_transformacoes': 10},
    ),
    DiaryBadge(
      id: 'borboleta',
      emoji: '🦋',
      nome: 'Borboleta',
      descricao: 'Transformou 25 erros em acertos',
      hint: 'Você está evoluindo constantemente!',
      categoria: BadgeCategory.transformacao,
      raridade: BadgeRarity.raro,
      xpRecompensa: 100, // ✅ Reduzido de 300
      criterios: {'total_transformacoes': 25},
    ),
    DiaryBadge(
      id: 'mestre_erro',
      emoji: '🏆',
      nome: 'Mestre do Erro',
      descricao: 'Dominou erros em 10 tópicos diferentes',
      hint: 'Transforme erros em diversas matérias',
      categoria: BadgeCategory.transformacao,
      raridade: BadgeRarity.epico,
      xpRecompensa: 150, // ✅ Reduzido de 500
      criterios: {'topicos_dominados': 10},
    ),

    // ═══════════════════════════════════════════
    // 📅 BADGES DE CONSISTÊNCIA
    // Onde aparecem: Home (ao abrir app)
    // ═══════════════════════════════════════════
    DiaryBadge(
      id: 'consistente',
      emoji: '📅',
      nome: 'Consistente',
      descricao: 'Fez anotações por 7 dias seguidos',
      hint: 'Anote algo todos os dias por uma semana',
      categoria: BadgeCategory.consistencia,
      raridade: BadgeRarity.incomum,
      xpRecompensa: 50, // ✅ Reduzido de 100
      criterios: {'streak_dias': 7},
    ),
    DiaryBadge(
      id: 'dedicado',
      emoji: '🗓️',
      nome: 'Dedicado',
      descricao: 'Fez anotações por 30 dias',
      hint: 'Um mês inteiro de dedicação!',
      categoria: BadgeCategory.consistencia,
      raridade: BadgeRarity.raro,
      xpRecompensa: 100, // ✅ Reduzido de 300
      criterios: {'streak_dias': 30},
    ),
    DiaryBadge(
      id: 'lenda_365',
      emoji: '🌳',
      nome: 'Árvore do Conhecimento',
      descricao: 'Usou o Diário por 365 dias',
      hint: 'Um ano completo de aprendizado!',
      categoria: BadgeCategory.consistencia,
      raridade: BadgeRarity.lendario,
      xpRecompensa: 300, // ✅ Reduzido de 1000
      criterios: {'dias_uso_total': 365},
    ),

    // ═══════════════════════════════════════════
    // 😊 BADGES DE EMOÇÃO
    // Onde aparecem: Tela de Resultado
    // ═══════════════════════════════════════════
    DiaryBadge(
      id: 'bem_estar',
      emoji: '😊',
      nome: 'Bem-Estar',
      descricao: '5 sessões consecutivas com emoção positiva',
      hint: 'Mantenha-se feliz enquanto aprende!',
      categoria: BadgeCategory.emocao,
      raridade: BadgeRarity.comum,
      xpRecompensa: 50, // ✅ Reduzido de 75
      criterios: {'sessoes_felizes_consecutivas': 5},
    ),
    DiaryBadge(
      id: 'equilibrado',
      emoji: '🧘',
      nome: 'Equilibrado',
      descricao: 'Manteve emoção 😊 ou 🙂 por 14 dias',
      hint: 'Equilíbrio emocional é chave para aprender',
      categoria: BadgeCategory.emocao,
      raridade: BadgeRarity.incomum,
      xpRecompensa: 75, // ✅ Reduzido de 150
      criterios: {'dias_emocao_positiva': 14},
    ),
    DiaryBadge(
      id: 'autoconsciente',
      emoji: '🪞',
      nome: 'Autoconsciente',
      descricao: 'Registrou emoções por 30 dias',
      hint: 'Conhecer suas emoções é o primeiro passo',
      categoria: BadgeCategory.emocao,
      raridade: BadgeRarity.raro,
      xpRecompensa: 100, // ✅ Reduzido de 200
      criterios: {'dias_com_emocao_registrada': 30},
    ),

    // ═══════════════════════════════════════════
    // ⏰ BADGES DE REVISÃO (FUTURO: Spaced Repetition)
    // Onde aparecem: Tela de Resultado
    // ═══════════════════════════════════════════
    DiaryBadge(
      id: 'revisor',
      emoji: '📖',
      nome: 'Revisor',
      descricao: 'Completou 10 revisões no prazo',
      hint: 'Revise suas anotações quando indicado',
      categoria: BadgeCategory.revisao,
      raridade: BadgeRarity.comum,
      xpRecompensa: 50, // ✅ Reduzido de 100
      criterios: {'revisoes_no_prazo': 10},
    ),
    DiaryBadge(
      id: 'pontual',
      emoji: '⏰',
      nome: 'Pontual',
      descricao: 'Zero revisões atrasadas por 7 dias',
      hint: 'Não deixe nenhuma revisão atrasar',
      categoria: BadgeCategory.revisao,
      raridade: BadgeRarity.incomum,
      xpRecompensa: 75, // ✅ Reduzido de 150
      criterios: {'dias_sem_atraso': 7},
    ),
    DiaryBadge(
      id: 'memoria_elefante',
      emoji: '🐘',
      nome: 'Memória de Elefante',
      descricao: '30 revisões sem errar',
      hint: 'Revise e acerte todas!',
      categoria: BadgeCategory.revisao,
      raridade: BadgeRarity.raro,
      xpRecompensa: 150, // ✅ Reduzido de 300
      criterios: {'revisoes_sem_erro': 30},
    ),

    // ═══════════════════════════════════════════
    // 🏆 BADGES ESPECIAIS
    // Onde aparecem: Tela de Resultado / Home
    // ═══════════════════════════════════════════
    DiaryBadge(
      id: 'ascensao',
      emoji: '📈',
      nome: 'Em Ascensão',
      descricao: 'Melhorou 20% de precisão em 1 semana',
      hint: 'Sua dedicação está valendo a pena!',
      categoria: BadgeCategory.especial,
      raridade: BadgeRarity.raro,
      xpRecompensa: 100, // ✅ Reduzido de 250
      criterios: {'melhoria_semanal_percentual': 20},
    ),
    DiaryBadge(
      id: 'foco_total',
      emoji: '🎯',
      nome: 'Foco Total',
      descricao: '100% de precisão em uma sessão completa',
      hint: 'Acerte todas em uma sessão!',
      categoria: BadgeCategory.especial,
      raridade: BadgeRarity.raro,
      xpRecompensa: 75, // ✅ Reduzido de 200
      criterios: {'sessao_100_precisao': true},
    ),
    DiaryBadge(
      id: 'lenda_diario',
      emoji: '👑',
      nome: 'Lenda do Diário',
      descricao: 'Desbloqueou todas as outras badges',
      hint: 'A conquista suprema!',
      categoria: BadgeCategory.especial,
      raridade: BadgeRarity.lendario,
      xpRecompensa: 500, // ✅ Reduzido de 1000
      criterios: {'todas_badges': true},
    ),
  ];

  /// Buscar badge por ID
  static DiaryBadge? getBadgeById(String id) {
    try {
      return todas.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filtrar badges por categoria
  static List<DiaryBadge> getBadgesByCategory(BadgeCategory categoria) {
    return todas.where((b) => b.categoria == categoria).toList();
  }

  /// Filtrar badges por raridade
  static List<DiaryBadge> getBadgesByRarity(BadgeRarity raridade) {
    return todas.where((b) => b.raridade == raridade).toList();
  }

  /// Total de badges
  static int get totalBadges => todas.length;

  /// Total de XP possível
  static int get totalXpPossivel =>
      todas.fold(0, (sum, badge) => sum + badge.xpRecompensa);
}
