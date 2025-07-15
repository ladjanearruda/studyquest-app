// lib/core/data/questoes_visuais_data.dart
import '../models/questao_visual.dart';

class QuestoesVisuaisData {
  // Modo Descoberta - 5 imagens contextuais
  static const Map<String, String> modoDescoberta = {
    'questao_1': 'assets/images/questoes/modo_descoberta/principal.jpg',
    'questao_2': 'assets/images/questoes/modo_descoberta/tech.jpg',
    'questao_3': 'assets/images/questoes/modo_descoberta/geo.jpg',
    'questao_4': 'assets/images/questoes/modo_descoberta/patterns.jpg',
    'questao_5': 'assets/images/questoes/modo_descoberta/lab.jpg',
  };

  // Questões específicas por série - BASEADO NAS IMAGENS REAIS DO DEV 2
  static const List<QuestaoVisual> todasQuestoes = [
    // ===== 6º ANO (6 imagens) =====
    QuestaoVisual(
      questaoId: 'MAT_6_001',
      imagemPath: 'assets/images/questoes/6ano/6ano_001_contagem_macacos.png',
      descricao: 'Contagem de macacos',
      serie: '6ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_6_002',
      imagemPath: 'assets/images/questoes/6ano/6ano_002_divisao_frutas.png',
      descricao: 'Divisão de frutas',
      serie: '6ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_6_003',
      imagemPath: 'assets/images/questoes/6ano/6ano_003_fracoes_mochila.png',
      descricao: 'Frações com mochila',
      serie: '6ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_6_004',
      imagemPath: 'assets/images/questoes/6ano/6ano_004_area_retangulo.png',
      descricao: 'Área do retângulo',
      serie: '6ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_6_005',
      imagemPath: 'assets/images/questoes/6ano/6ano_005_sementes_semana.png',
      descricao: 'Sementes da semana',
      serie: '6ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_6_006',
      imagemPath: 'assets/images/questoes/6ano/retangulo_fracao.png',
      descricao: 'Frações 3/8',
      serie: '6ano',
      tipo: 'especifica',
    ),

    // ===== 7º ANO (8 imagens) =====
    QuestaoVisual(
      questaoId: 'MAT_7_001',
      imagemPath: 'assets/images/questoes/7ano/7ano_001_equacao_balanca.png',
      descricao: 'Equação com balança',
      serie: '7ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_7_002',
      imagemPath: 'assets/images/questoes/7ano/7ano_002_proporcao_cestas.png',
      descricao: 'Proporção com cestas',
      serie: '7ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_7_003',
      imagemPath:
          'assets/images/questoes/7ano/7ano_003_angulos_complementares.png',
      descricao: 'Ângulos complementares',
      serie: '7ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_7_004',
      imagemPath:
          'assets/images/questoes/7ano/7ano_004_receita_proporcional.png',
      descricao: 'Receita proporcional',
      serie: '7ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_7_005',
      imagemPath: 'assets/images/questoes/7ano/7ano_005_angulo_reto.png',
      descricao: 'Ângulo reto',
      serie: '7ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_7_006',
      imagemPath: 'assets/images/questoes/7ano/area_hachurada.png',
      descricao: 'Área hachurada',
      serie: '7ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_7_007',
      imagemPath: 'assets/images/questoes/7ano/grafico_vendas.png',
      descricao: 'Gráfico de vendas',
      serie: '7ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_7_008',
      imagemPath: 'assets/images/questoes/7ano/quadrados_proporcionais.png',
      descricao: 'Quadrados proporcionais',
      serie: '7ano',
      tipo: 'especifica',
    ),

    // ===== 8º ANO (6 imagens) =====
    QuestaoVisual(
      questaoId: 'MAT_8_001',
      imagemPath: 'assets/images/questoes/8ano/8ano_001_potencias_blocos.png',
      descricao: 'Potências com blocos',
      serie: '8ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_8_002',
      imagemPath:
          'assets/images/questoes/8ano/8ano_002_triangulo_retangulo.png',
      descricao: 'Triângulo retângulo',
      serie: '8ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_8_003',
      imagemPath: 'assets/images/questoes/8ano/8ano_003_sistema_equacoes.png',
      descricao: 'Sistema de equações',
      serie: '8ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_8_004',
      imagemPath: 'assets/images/questoes/8ano/escada_pitagoras.png',
      descricao: 'Escada de Pitágoras',
      serie: '8ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_8_005',
      imagemPath: 'assets/images/questoes/8ano/reta_plano_cartesiano.png',
      descricao: 'Reta no plano cartesiano',
      serie: '8ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_8_006',
      imagemPath: 'assets/images/questoes/8ano/triangulo_grid.png',
      descricao: 'Triângulo em grade',
      serie: '8ano',
      tipo: 'especifica',
    ),

    // ===== 9º ANO (5 imagens) =====
    QuestaoVisual(
      questaoId: 'MAT_9_001',
      imagemPath: 'assets/images/questoes/9ano/9ano_001_funcao_linear.png',
      descricao: 'Função linear',
      serie: '9ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_9_002',
      imagemPath:
          'assets/images/questoes/9ano/9ano_002_probabilidade_dados.png',
      descricao: 'Probabilidade com dados',
      serie: '9ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_9_003',
      imagemPath: 'assets/images/questoes/9ano/parabola_vertice.png',
      descricao: 'Parábola e vértice',
      serie: '9ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_9_004',
      imagemPath: 'assets/images/questoes/9ano/roleta_probabilidade.png',
      descricao: 'Roleta de probabilidade',
      serie: '9ano',
      tipo: 'especifica',
    ),
    QuestaoVisual(
      questaoId: 'MAT_9_005',
      imagemPath: 'assets/images/questoes/9ano/triangulo_trigonometria.png',
      descricao: 'Triângulo trigonometria',
      serie: '9ano',
      tipo: 'especifica',
    ),

    // ===== ENSINO MÉDIO (1 imagem por enquanto) =====
    QuestaoVisual(
      questaoId: 'MAT_EM_001',
      imagemPath: 'assets/images/questoes/ensino-medio/desconto_produto.png',
      descricao: 'Desconto do produto',
      serie: 'ensino-medio',
      tipo: 'especifica',
    ),
  ];

  // ===== FUNÇÕES UTILITÁRIAS =====

  /// Obter imagem por ID de questão específica
  static String? getImagemPorQuestaoId(String questaoId) {
    try {
      final questao = todasQuestoes.firstWhere(
        (q) => q.questaoId == questaoId,
      );
      return questao.imagemPath;
    } catch (e) {
      return null; // Questão não encontrada
    }
  }

  /// Obter imagem do Modo Descoberta por número da questão (1-5)
  static String? getImagemModoDescoberta(int numeroQuestao) {
    final key = 'questao_$numeroQuestao';
    return modoDescoberta[key];
  }

  /// Obter todas as questões de uma série específica
  static List<QuestaoVisual> getQuestoesPorSerie(String serie) {
    return todasQuestoes.where((q) => q.serie == serie).toList();
  }

  /// Obter imagem aleatória de uma série específica
  static String? getImagemAleatoriaPorSerie(String serie) {
    final questoesSerie = getQuestoesPorSerie(serie);
    if (questoesSerie.isEmpty) return null;

    final indiceAleatorio = DateTime.now().millisecond % questoesSerie.length;
    return questoesSerie[indiceAleatorio].imagemPath;
  }

  /// Obter todas as imagens disponíveis (para debug)
  static List<String> getAllImagePaths() {
    final List<String> paths = [];

    // Adicionar imagens do modo descoberta
    paths.addAll(modoDescoberta.values);

    // Adicionar imagens específicas
    paths.addAll(todasQuestoes.map((q) => q.imagemPath));

    return paths;
  }

  /// Verificar se questão tem imagem específica
  static bool hasImagemEspecifica(String questaoId) {
    return getImagemPorQuestaoId(questaoId) != null;
  }

  /// Obter estatísticas das imagens
  static Map<String, int> getEstatisticas() {
    final stats = <String, int>{};

    for (final questao in todasQuestoes) {
      stats[questao.serie] = (stats[questao.serie] ?? 0) + 1;
    }

    stats['modo_descoberta'] = modoDescoberta.length;
    stats['total'] = todasQuestoes.length + modoDescoberta.length;

    return stats;
  }
}
