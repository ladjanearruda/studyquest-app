// lib/features/niveis/models/nivel_model.dart
// ✅ Sprint 7 Parte 2 - Sistema de Níveis MVP
// 📅 Criado: 06/02/2026

import 'dart:math';

/// Representa um Tier (grupo de níveis)
enum NivelTier {
  iniciante, // 🌱 Níveis 1-5
  aprendiz, // 🌿 Níveis 6-15
  explorador, // 🌳 Níveis 16-30
  mestre, // 🏆 Níveis 31-50
  lenda, // 👑 Níveis 51+
}

/// Extensão para propriedades do Tier
extension NivelTierExtension on NivelTier {
  String get nome {
    switch (this) {
      case NivelTier.iniciante:
        return 'Iniciante';
      case NivelTier.aprendiz:
        return 'Aprendiz';
      case NivelTier.explorador:
        return 'Explorador';
      case NivelTier.mestre:
        return 'Mestre';
      case NivelTier.lenda:
        return 'Lenda';
    }
  }

  String get emoji {
    switch (this) {
      case NivelTier.iniciante:
        return '🌱';
      case NivelTier.aprendiz:
        return '🌿';
      case NivelTier.explorador:
        return '🌳';
      case NivelTier.mestre:
        return '🏆';
      case NivelTier.lenda:
        return '👑';
    }
  }

  String get descricao {
    switch (this) {
      case NivelTier.iniciante:
        return 'Começando sua jornada na floresta';
      case NivelTier.aprendiz:
        return 'Aprendendo os segredos da selva';
      case NivelTier.explorador:
        return 'Desbravando territórios desconhecidos';
      case NivelTier.mestre:
        return 'Dominando os mistérios da Amazônia';
      case NivelTier.lenda:
        return 'Uma lenda viva da floresta';
    }
  }

  /// Retorna o range de níveis do tier
  (int min, int max) get rangeNiveis {
    switch (this) {
      case NivelTier.iniciante:
        return (1, 5);
      case NivelTier.aprendiz:
        return (6, 15);
      case NivelTier.explorador:
        return (16, 30);
      case NivelTier.mestre:
        return (31, 50);
      case NivelTier.lenda:
        return (51, 999); // Infinito
    }
  }
}

/// Representa um desbloqueio por nível
class Desbloqueio {
  final int nivelRequerido;
  final String titulo;
  final String descricao;
  final String icone;
  final String tipo; // 'feature', 'tema', 'badge', 'avatar'

  const Desbloqueio({
    required this.nivelRequerido,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.tipo,
  });
}

/// Classe principal do Sistema de Níveis
class NivelSystem {
  // ===== CONSTANTES =====

  /// Fator de crescimento exponencial (8%)
  static const double _fatorCrescimento = 1.08;

  /// XP base para o primeiro nível
  static const int _xpBase = 100;

  // ===== CÁLCULOS DE XP =====

  /// Calcula XP necessário para passar de um nível para o próximo
  /// Fórmula: 100 × (1.08)^nivel
  static int xpParaProximoNivel(int nivelAtual) {
    return (_xpBase * pow(_fatorCrescimento, nivelAtual)).round();
  }

  /// Calcula XP total necessário para alcançar um nível específico
  static int xpTotalParaNivel(int nivel) {
    if (nivel <= 1) return 0;

    int total = 0;
    for (int i = 1; i < nivel; i++) {
      total += xpParaProximoNivel(i);
    }
    return total;
  }

  /// Calcula o nível baseado no XP total
  static int nivelPorXpTotal(int xpTotal) {
    int nivel = 1;
    int xpAcumulado = 0;

    while (xpAcumulado + xpParaProximoNivel(nivel) <= xpTotal) {
      xpAcumulado += xpParaProximoNivel(nivel);
      nivel++;
    }

    return nivel;
  }

  /// Calcula XP restante no nível atual
  static int xpNoNivelAtual(int xpTotal) {
    int nivel = nivelPorXpTotal(xpTotal);
    int xpParaEsteNivel = xpTotalParaNivel(nivel);
    return xpTotal - xpParaEsteNivel;
  }

  /// Calcula progresso percentual no nível atual (0.0 a 1.0)
  static double progressoNoNivel(int xpTotal) {
    int nivel = nivelPorXpTotal(xpTotal);
    int xpAtual = xpNoNivelAtual(xpTotal);
    int xpNecessario = xpParaProximoNivel(nivel);

    if (xpNecessario == 0) return 1.0;
    return (xpAtual / xpNecessario).clamp(0.0, 1.0);
  }

  /// Calcula XP faltando para o próximo nível
  static int xpFaltandoParaProximoNivel(int xpTotal) {
    int nivel = nivelPorXpTotal(xpTotal);
    int xpAtual = xpNoNivelAtual(xpTotal);
    int xpNecessario = xpParaProximoNivel(nivel);

    return xpNecessario - xpAtual;
  }

  // ===== TIERS =====

  /// Retorna o tier baseado no nível
  static NivelTier tierPorNivel(int nivel) {
    if (nivel <= 5) return NivelTier.iniciante;
    if (nivel <= 15) return NivelTier.aprendiz;
    if (nivel <= 30) return NivelTier.explorador;
    if (nivel <= 50) return NivelTier.mestre;
    return NivelTier.lenda;
  }

  /// Verifica se vai mudar de tier ao subir de nível
  static bool vaiMudarDeTier(int nivelAtual) {
    return tierPorNivel(nivelAtual) != tierPorNivel(nivelAtual + 1);
  }

  /// Retorna o próximo tier (se existir)
  static NivelTier? proximoTier(int nivelAtual) {
    final tierAtual = tierPorNivel(nivelAtual);
    switch (tierAtual) {
      case NivelTier.iniciante:
        return NivelTier.aprendiz;
      case NivelTier.aprendiz:
        return NivelTier.explorador;
      case NivelTier.explorador:
        return NivelTier.mestre;
      case NivelTier.mestre:
        return NivelTier.lenda;
      case NivelTier.lenda:
        return null; // Já é o máximo
    }
  }

  // ===== DESBLOQUEIOS =====

  /// Lista de todos os desbloqueios do jogo
  static const List<Desbloqueio> _desbloqueios = [
    // Tier 1 - Iniciante
    Desbloqueio(
      nivelRequerido: 3,
      titulo: 'Customização Básica',
      descricao: 'Personalize seu avatar com acessórios básicos',
      icone: '🎨',
      tipo: 'avatar',
    ),
    Desbloqueio(
      nivelRequerido: 5,
      titulo: 'Diário do Explorador',
      descricao: 'Acesso ao diário para anotar seus aprendizados',
      icone: '📒',
      tipo: 'feature',
    ),

    // Tier 2 - Aprendiz
    Desbloqueio(
      nivelRequerido: 10,
      titulo: 'Observatório',
      descricao: 'Veja rankings e compare seu progresso',
      icone: '🔭',
      tipo: 'feature',
    ),
    Desbloqueio(
      nivelRequerido: 15,
      titulo: 'Insights IA',
      descricao: 'Receba dicas personalizadas da IA no diário',
      icone: '🤖',
      tipo: 'feature',
    ),

    // Tier 3 - Explorador
    Desbloqueio(
      nivelRequerido: 20,
      titulo: 'Rankings Avançados',
      descricao: 'Acesse rankings detalhados por matéria',
      icone: '📊',
      tipo: 'feature',
    ),
    Desbloqueio(
      nivelRequerido: 25,
      titulo: 'Tema Oceano',
      descricao: 'Desbloqueie a aventura no Oceano Profundo!',
      icone: '🌊',
      tipo: 'tema',
    ),
    Desbloqueio(
      nivelRequerido: 30,
      titulo: 'Sistema de Badges',
      descricao: 'Colecione todas as conquistas disponíveis',
      icone: '🏅',
      tipo: 'feature',
    ),

    // Tier 4 - Mestre
    Desbloqueio(
      nivelRequerido: 35,
      titulo: 'IA Avançada',
      descricao: 'Recomendações ainda mais precisas',
      icone: '🧠',
      tipo: 'feature',
    ),
    Desbloqueio(
      nivelRequerido: 40,
      titulo: 'Features Premium',
      descricao: 'Acesso a funcionalidades exclusivas',
      icone: '💎',
      tipo: 'feature',
    ),
    Desbloqueio(
      nivelRequerido: 50,
      titulo: 'Status Mestre',
      descricao: 'Reconhecimento especial como Mestre da Floresta',
      icone: '🏆',
      tipo: 'badge',
    ),

    // Tier 5 - Lenda
    Desbloqueio(
      nivelRequerido: 51,
      titulo: 'Status Lenda',
      descricao: 'Você é uma lenda viva! Parabéns!',
      icone: '👑',
      tipo: 'badge',
    ),
  ];

  /// Retorna desbloqueios para um nível específico
  static List<Desbloqueio> desbloqueiosNoNivel(int nivel) {
    return _desbloqueios.where((d) => d.nivelRequerido == nivel).toList();
  }

  /// Retorna todos os desbloqueios até um nível
  static List<Desbloqueio> desbloqueiosAteNivel(int nivel) {
    return _desbloqueios.where((d) => d.nivelRequerido <= nivel).toList();
  }

  /// Retorna próximos desbloqueios a partir do nível atual
  static List<Desbloqueio> proximosDesbloqueios(int nivelAtual,
      {int limite = 3}) {
    return _desbloqueios
        .where((d) => d.nivelRequerido > nivelAtual)
        .take(limite)
        .toList();
  }

  /// Verifica se uma feature está desbloqueada
  static bool featureDesbloqueada(int nivelAtual, String tituloFeature) {
    final desbloqueio = _desbloqueios.firstWhere(
      (d) => d.titulo == tituloFeature,
      orElse: () => const Desbloqueio(
        nivelRequerido: 999,
        titulo: '',
        descricao: '',
        icone: '',
        tipo: '',
      ),
    );
    return nivelAtual >= desbloqueio.nivelRequerido;
  }

  // ===== MENSAGENS MOTIVACIONAIS =====

  /// Retorna mensagem de level up baseada no nível
  static String mensagemLevelUp(int novoNivel) {
    final tier = tierPorNivel(novoNivel);

    // Mensagens especiais para níveis importantes
    if (novoNivel == 5) {
      return '🎉 Você completou o tutorial! O Diário do Explorador está disponível!';
    }
    if (novoNivel == 10) {
      return '🔭 O Observatório foi desbloqueado! Veja como você se compara!';
    }
    if (novoNivel == 25) {
      return '🌊 INCRÍVEL! O Tema Oceano está desbloqueado! Uma nova aventura te espera!';
    }
    if (novoNivel == 50) {
      return '🏆 VOCÊ É UM MESTRE! Poucos chegaram tão longe!';
    }
    if (novoNivel == 51) {
      return '👑 LENDÁRIO! Você transcendeu todos os limites!';
    }

    // Mensagens por tier
    final mensagens = {
      NivelTier.iniciante: [
        'Continue assim, jovem explorador!',
        'A floresta revela seus segredos!',
        'Cada passo te torna mais forte!',
      ],
      NivelTier.aprendiz: [
        'Seu conhecimento cresce rapidamente!',
        'A selva reconhece seu esforço!',
        'Você está no caminho certo!',
      ],
      NivelTier.explorador: [
        'Você domina os mistérios da floresta!',
        'Um verdadeiro desbravador!',
        'A Amazônia é seu lar!',
      ],
      NivelTier.mestre: [
        'Poucos alcançam esse nível!',
        'Você é uma inspiração!',
        'Mestre da selva!',
      ],
      NivelTier.lenda: [
        'Uma lenda viva!',
        'Seu nome será lembrado!',
        'Você transcendeu!',
      ],
    };

    final lista = mensagens[tier]!;
    return lista[novoNivel % lista.length];
  }

  // ===== ESTIMATIVAS =====

  /// Estima sessões necessárias para alcançar um nível
  /// Assume média de 326 XP por sessão (20 questões, 60% acerto)
  static int sessoesParaNivel(int nivelAlvo,
      {int nivelAtual = 1, int xpAtual = 0}) {
    const xpMedioPorSessao = 326;

    int xpNecessario = xpTotalParaNivel(nivelAlvo) - xpAtual;
    if (xpNecessario <= 0) return 0;

    return (xpNecessario / xpMedioPorSessao).ceil();
  }

  /// Estima tempo (em dias) para alcançar um nível
  /// Assume 1 sessão por dia em média
  static int diasParaNivel(int nivelAlvo,
      {int nivelAtual = 1, int xpAtual = 0}) {
    return sessoesParaNivel(nivelAlvo,
        nivelAtual: nivelAtual, xpAtual: xpAtual);
  }
}

/// Estado do nível do usuário (para uso no provider)
class NivelUsuario {
  final int xpTotal;
  final int nivel;
  final int xpNoNivel;
  final int xpParaProximo;
  final double progresso;
  final NivelTier tier;

  const NivelUsuario({
    required this.xpTotal,
    required this.nivel,
    required this.xpNoNivel,
    required this.xpParaProximo,
    required this.progresso,
    required this.tier,
  });

  /// Cria estado inicial (nível 1, 0 XP)
  factory NivelUsuario.inicial() {
    return const NivelUsuario(
      xpTotal: 0,
      nivel: 1,
      xpNoNivel: 0,
      xpParaProximo: 100,
      progresso: 0.0,
      tier: NivelTier.iniciante,
    );
  }

  /// Cria estado a partir do XP total
  factory NivelUsuario.fromXpTotal(int xpTotal) {
    final nivel = NivelSystem.nivelPorXpTotal(xpTotal);
    final xpNoNivel = NivelSystem.xpNoNivelAtual(xpTotal);
    final xpParaProximo = NivelSystem.xpParaProximoNivel(nivel);
    final progresso = NivelSystem.progressoNoNivel(xpTotal);
    final tier = NivelSystem.tierPorNivel(nivel);

    return NivelUsuario(
      xpTotal: xpTotal,
      nivel: nivel,
      xpNoNivel: xpNoNivel,
      xpParaProximo: xpParaProximo,
      progresso: progresso,
      tier: tier,
    );
  }

  /// Cria novo estado após ganhar XP
  NivelUsuario ganharXp(int xpGanho) {
    return NivelUsuario.fromXpTotal(xpTotal + xpGanho);
  }

  /// Verifica se subiu de nível comparando com estado anterior
  bool subiuDeNivel(NivelUsuario anterior) {
    return nivel > anterior.nivel;
  }

  /// Verifica se mudou de tier comparando com estado anterior
  bool mudouDeTier(NivelUsuario anterior) {
    return tier != anterior.tier;
  }

  /// Retorna desbloqueios novos comparando com estado anterior
  List<Desbloqueio> novosDesbloqueios(NivelUsuario anterior) {
    if (nivel <= anterior.nivel) return [];

    List<Desbloqueio> novos = [];
    for (int n = anterior.nivel + 1; n <= nivel; n++) {
      novos.addAll(NivelSystem.desbloqueiosNoNivel(n));
    }
    return novos;
  }

  /// XP faltando para o próximo nível
  int get xpFaltando => xpParaProximo - xpNoNivel;

  /// Descrição formatada do nível
  String get descricaoCompleta => 'Nível $nivel - ${tier.nome} ${tier.emoji}';

  /// Descrição curta
  String get descricaoCurta => 'Nv. $nivel ${tier.emoji}';

  @override
  String toString() {
    return 'NivelUsuario(nivel: $nivel, xpTotal: $xpTotal, tier: ${tier.nome})';
  }
}
