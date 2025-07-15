// lib/features/modo_descoberta/data/questoes_nivelamento.dart

import '../models/questao_descoberta.dart';
import '../../onboarding/screens/onboarding_screen.dart';

/// Sistema de pools de questões organizadas por nível escolar
/// Agora inclui questões com imagens específicas do sistema visual
class QuestoesNivelamento {
  /// Retorna pool de questões baseado no nível educacional do usuário
  static List<QuestaoDescoberta> getQuestoesPorNivel(EducationLevel nivel) {
    switch (nivel) {
      case EducationLevel.fundamental6:
        return _questoes6ano;
      case EducationLevel.fundamental7:
        return _questoes7ano;
      case EducationLevel.fundamental8:
        return _questoes8ano;
      case EducationLevel.fundamental9:
        return _questoes9ano;
      case EducationLevel.medio1:
        return _questoes1anoEM;
      case EducationLevel.medio2:
        return _questoes2anoEM;
      case EducationLevel.medio3:
        return _questoes3anoEM;
      case EducationLevel.completed:
        return _questoesEnemStyle;
    }
  }

  /// Seleciona 5 questões aleatórias do pool do nível
  static List<QuestaoDescoberta> selecionarQuestoesPara(EducationLevel nivel) {
    final pool = getQuestoesPorNivel(nivel);
    pool.shuffle(); // Embaralha o pool
    return pool.take(5).toList(); // Pega as primeiras 5
  }

  // ===== 📖 FUNDAMENTAL II =====

  /// 6º ano - Operações básicas, frações simples, geometria plana
  static final List<QuestaoDescoberta> _questoes6ano = [
    // QUESTÃO VISUAL - Contagem com macacos
    QuestaoDescoberta(
      id: '6ano_001_visual',
      enunciado:
          'Observe a imagem. Quantos macacos você consegue contar no total?',
      alternativas: ['15', '18', '21', '24'],
      respostaCorreta: 2, // 21
      explicacao: 'Contando todos os macacos na imagem: 7 + 6 + 8 = 21 macacos',
      assunto: 'Contagem e Adição',
      dificuldade: 1,
      imagemEspecifica: 'images/questoes/6ano/6ano_001_contagem_macacos.png',
    ),

    // QUESTÃO VISUAL - Divisão de frutas
    QuestaoDescoberta(
      id: '6ano_002_visual',
      enunciado:
          'Na imagem, as frutas devem ser divididas igualmente entre as cestas. Quantas frutas ficam em cada cesta?',
      alternativas: ['6', '8', '9', '12'],
      respostaCorreta: 1, // 8
      explicacao: 'Total de 48 frutas ÷ 6 cestas = 8 frutas por cesta',
      assunto: 'Divisão',
      dificuldade: 1,
      imagemEspecifica:
          'assets/images/questoes/6ano/6ano_002_divisao_frutas.png',
    ),

    // QUESTÃO VISUAL - Área retângulo
    QuestaoDescoberta(
      id: '6ano_003_visual',
      enunciado:
          'Observe o retângulo na imagem. Se o comprimento é 8m e a largura é 5m, qual é a área?',
      alternativas: ['26 m²', '35 m²', '40 m²', '45 m²'],
      respostaCorreta: 2, // 40 m²
      explicacao: 'Área do retângulo = comprimento × largura = 8 × 5 = 40 m²',
      assunto: 'Área de Retângulos',
      dificuldade: 2,
      imagemEspecifica:
          'assets/images/questoes/6ano/6ano_004_area_retangulo.png',
    ),

    // QUESTÕES TRADICIONAIS
    QuestaoDescoberta(
      id: '6ano_004',
      enunciado:
          'Na sua mochila, 2/5 do espaço está ocupado com água. Que fração representa o espaço livre?',
      alternativas: ['2/5', '3/5', '1/5', '4/5'],
      respostaCorreta: 1, // 3/5
      explicacao: 'Se 2/5 está ocupado, então 5/5 - 2/5 = 3/5 está livre',
      assunto: 'Frações',
      dificuldade: 2,
    ),

    QuestaoDescoberta(
      id: '6ano_005',
      enunciado:
          'João tem 45 reais e quer comprar 3 brinquedos de mesmo preço. Quanto pode custar cada brinquedo no máximo?',
      alternativas: ['12 reais', '15 reais', '18 reais', '20 reais'],
      respostaCorreta: 1, // 15 reais
      explicacao: '45 ÷ 3 = 15 reais por brinquedo',
      assunto: 'Divisão com dinheiro',
      dificuldade: 2,
    ),
  ];

  /// 7º ano - Equações 1º grau, proporcionalidade, ângulos
  static final List<QuestaoDescoberta> _questoes7ano = [
    // QUESTÃO VISUAL - Equação na balança
    QuestaoDescoberta(
      id: '7ano_001_visual',
      enunciado:
          'Observe a balança equilibrada na imagem. Qual é o valor de x?',
      alternativas: ['3', '5', '7', '9'],
      respostaCorreta: 1, // 5
      explicacao: 'Na balança: x + 2 = 7, então x = 7 - 2 = 5',
      assunto: 'Equações do 1º grau',
      dificuldade: 2,
      imagemEspecifica:
          'assets/images/questoes/7ano/7ano_001_equacao_balanca.png',
    ),

    // QUESTÃO VISUAL - Área hachurada
    QuestaoDescoberta(
      id: '7ano_002_visual',
      enunciado: 'Na figura, qual é a área da região hachurada (colorida)?',
      alternativas: ['12 cm²', '15 cm²', '18 cm²', '20 cm²'],
      respostaCorreta: 2, // 18 cm²
      explicacao:
          'Área total do retângulo menos área do quadrado pequeno: (6×5) - (3×4) = 30 - 12 = 18 cm²',
      assunto: 'Área de figuras compostas',
      dificuldade: 3,
      imagemEspecifica: 'assets/images/questoes/7ano/area_hachurada.png',
    ),

    // QUESTÃO VISUAL - Gráfico de vendas
    QuestaoDescoberta(
      id: '7ano_003_visual',
      enunciado:
          'Observando o gráfico de vendas, em qual mês houve maior venda?',
      alternativas: ['Janeiro', 'Fevereiro', 'Março', 'Abril'],
      respostaCorreta: 2, // Março
      explicacao:
          'No gráfico, a barra de março é a mais alta, indicando maior volume de vendas',
      assunto: 'Interpretação de gráficos',
      dificuldade: 2,
      imagemEspecifica: 'assets/images/questoes/7ano/grafico_vendas.png',
    ),

    // QUESTÕES TRADICIONAIS
    QuestaoDescoberta(
      id: '7ano_004',
      enunciado: 'Resolva a equação: 3x + 5 = 20',
      alternativas: ['x = 3', 'x = 5', 'x = 7', 'x = 10'],
      respostaCorreta: 1, // x = 5
      explicacao: '3x = 20 - 5 = 15, então x = 15 ÷ 3 = 5',
      assunto: 'Equações do 1º grau',
      dificuldade: 2,
    ),

    QuestaoDescoberta(
      id: '7ano_005',
      enunciado: 'Se 4 canetas custam R\$ 12, quanto custam 7 canetas?',
      alternativas: ['R\$ 18', 'R\$ 21', 'R\$ 24', 'R\$ 28'],
      respostaCorreta: 1, // R$ 21
      explicacao:
          'Regra de três: se 4 canetas = R\$ 12, então 7 canetas = (12 × 7) ÷ 4 = R\$ 21',
      assunto: 'Proporcionalidade',
      dificuldade: 2,
    ),
  ];

  /// 8º ano - Sistemas de equações, teorema de Pitágoras, potências
  static final List<QuestaoDescoberta> _questoes8ano = [
    // QUESTÃO VISUAL - Potências com blocos
    QuestaoDescoberta(
      id: '8ano_001_visual',
      enunciado:
          'Observe os blocos na figura. Qual potência representa o total de blocos?',
      alternativas: ['2³', '3²', '4²', '2⁴'],
      respostaCorreta: 0, // 2³
      explicacao: 'São 2 × 2 × 2 = 2³ = 8 blocos no total',
      assunto: 'Potenciação',
      dificuldade: 2,
      imagemEspecifica:
          'assets/images/questoes/8ano/8ano_001_potencias_blocos.png',
    ),

    // QUESTÃO VISUAL - Escada Pitágoras
    QuestaoDescoberta(
      id: '8ano_002_visual',
      enunciado:
          'Observe a escada apoiada na parede. Qual é a altura que ela alcança?',
      alternativas: ['3 m', '4 m', '5 m', '6 m'],
      respostaCorreta: 1, // 4 m
      explicacao:
          'Pelo Teorema de Pitágoras: h² = 5² - 3² = 25 - 9 = 16, então h = 4 m',
      assunto: 'Teorema de Pitágoras',
      dificuldade: 3,
      imagemEspecifica: 'assets/images/questoes/8ano/escada_pitagoras.png',
    ),

    // QUESTÃO VISUAL - Triângulo em grid
    QuestaoDescoberta(
      id: '8ano_003_visual',
      enunciado: 'No grid da figura, qual é a área do triângulo destacado?',
      alternativas: [
        '6 unidades²',
        '8 unidades²',
        '10 unidades²',
        '12 unidades²'
      ],
      respostaCorreta: 2, // 10 unidades²
      explicacao: 'Área = (base × altura) ÷ 2 = (5 × 4) ÷ 2 = 10 unidades²',
      assunto: 'Área de triângulos',
      dificuldade: 2,
      imagemEspecifica: 'images/questoes/8ano/triangulo_grid.png',
    ),

    // QUESTÃO VISUAL - Plano cartesiano
    QuestaoDescoberta(
      id: '8ano_004_visual',
      enunciado:
          'No plano cartesiano da imagem, quais são as coordenadas do ponto destacado?',
      alternativas: ['(2, 3)', '(3, 2)', '(-2, 3)', '(3, -2)'],
      respostaCorreta: 0, // (2, 3)
      explicacao: 'O ponto está localizado em x = 2 e y = 3, portanto (2, 3)',
      assunto: 'Plano cartesiano',
      dificuldade: 2,
      imagemEspecifica: 'assets/images/questoes/8ano/reta_plano_cartesiano.png',
    ),

    // QUESTÕES TRADICIONAIS
    QuestaoDescoberta(
      id: '8ano_005',
      enunciado: 'Calcule: 2³ + 3²',
      alternativas: ['15', '17', '19', '23'],
      respostaCorreta: 1, // 17
      explicacao: '2³ = 8 e 3² = 9, então 8 + 9 = 17',
      assunto: 'Potenciação',
      dificuldade: 2,
    ),

    QuestaoDescoberta(
      id: '8ano_006',
      enunciado: 'Resolva o sistema: x + y = 7 e x - y = 1',
      alternativas: ['x=3, y=4', 'x=4, y=3', 'x=5, y=2', 'x=2, y=5'],
      respostaCorreta: 1, // x=4, y=3
      explicacao:
          'Somando as equações: 2x = 8, então x = 4. Substituindo: 4 + y = 7, então y = 3',
      assunto: 'Sistemas de equações',
      dificuldade: 3,
    ),
  ];

  /// 9º ano - Funções 1º grau, probabilidade, trigonometria básica
  static final List<QuestaoDescoberta> _questoes9ano = [
    // QUESTÃO VISUAL - Função linear
    QuestaoDescoberta(
      id: '9ano_001_visual',
      enunciado:
          'Observe o gráfico da função. Qual é o valor de y quando x = 2?',
      alternativas: ['1', '2', '3', '4'],
      respostaCorreta: 2, // 3
      explicacao: 'Observando o gráfico, quando x = 2, y = 3',
      assunto: 'Funções do 1º grau',
      dificuldade: 3,
      imagemEspecifica:
          'assets/images/questoes/9ano/9ano_001_funcao_linear.png',
    ),

    // QUESTÃO VISUAL - Probabilidade com dados
    QuestaoDescoberta(
      id: '9ano_002_visual',
      enunciado:
          'Na imagem dos dados, qual é a probabilidade de sair um número par?',
      alternativas: ['1/4', '1/3', '1/2', '2/3'],
      respostaCorreta: 2, // 1/2
      explicacao:
          'Números pares: 2, 4, 6. Total: 1, 2, 3, 4, 5, 6. Probabilidade = 3/6 = 1/2',
      assunto: 'Probabilidade',
      dificuldade: 2,
      imagemEspecifica:
          'assets/images/questoes/9ano/9ano_002_probabilidade_dados.png',
    ),

    // QUESTÃO VISUAL - Parábola vértice
    QuestaoDescoberta(
      id: '9ano_003_visual',
      enunciado:
          'Observe o gráfico da parábola. Em que ponto ela atinge seu valor mínimo?',
      alternativas: ['(1, -2)', '(2, -1)', '(-1, 2)', '(0, 1)'],
      respostaCorreta: 0, // (1, -2)
      explicacao:
          'O vértice da parábola (ponto mais baixo) está em x = 1 e y = -2',
      assunto: 'Funções quadráticas',
      dificuldade: 3,
      imagemEspecifica: 'assets/images/questoes/9ano/parabola_vertice.png',
    ),

    // QUESTÕES TRADICIONAIS
    QuestaoDescoberta(
      id: '9ano_004',
      enunciado: 'A função f(x) = 2x + 3. Qual é o valor de f(5)?',
      alternativas: ['10', '11', '13', '15'],
      respostaCorreta: 2, // 13
      explicacao: 'f(5) = 2(5) + 3 = 10 + 3 = 13',
      assunto: 'Funções do 1º grau',
      dificuldade: 2,
    ),

    QuestaoDescoberta(
      id: '9ano_005',
      enunciado:
          'Em um triângulo retângulo, um cateto mede 3 e a hipotenusa mede 5. Quanto mede o outro cateto?',
      alternativas: ['3', '4', '5', '6'],
      respostaCorreta: 1, // 4
      explicacao:
          'Pelo Teorema de Pitágoras: c² = 5² - 3² = 25 - 9 = 16, então c = 4',
      assunto: 'Teorema de Pitágoras',
      dificuldade: 2,
    ),
  ];

  /// Ensino Médio - 1º ano
  static final List<QuestaoDescoberta> _questoes1anoEM = [
    QuestaoDescoberta(
      id: 'em1_001',
      enunciado: 'Qual é o domínio da função f(x) = √(x - 2)?',
      alternativas: ['x ≥ 2', 'x > 2', 'x ≤ 2', 'x ∈ ℝ'],
      respostaCorreta: 0, // x ≥ 2
      explicacao: 'Para existir raiz quadrada real, x - 2 ≥ 0, logo x ≥ 2',
      assunto: 'Domínio de funções',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: 'em1_002',
      enunciado:
          'Em uma PA, o primeiro termo é 3 e a razão é 5. Qual é o 10º termo?',
      alternativas: ['45', '48', '50', '53'],
      respostaCorreta: 1, // 48
      explicacao: 'a₁₀ = a₁ + 9r = 3 + 9(5) = 3 + 45 = 48',
      assunto: 'Progressão Aritmética',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: 'em1_003',
      enunciado: 'Calcule sen(30°)',
      alternativas: ['1/2', '√2/2', '√3/2', '1'],
      respostaCorreta: 0, // 1/2
      explicacao: 'sen(30°) = 1/2 (valor padrão da trigonometria)',
      assunto: 'Trigonometria',
      dificuldade: 2,
    ),
  ];

  /// Ensino Médio - 2º ano
  static final List<QuestaoDescoberta> _questoes2anoEM = [
    QuestaoDescoberta(
      id: 'em2_001',
      enunciado: 'Calcule log₂(8)',
      alternativas: ['2', '3', '4', '8'],
      respostaCorreta: 1, // 3
      explicacao: 'log₂(8) = x significa 2ˣ = 8. Como 2³ = 8, então x = 3',
      assunto: 'Logaritmos',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: 'em2_002',
      enunciado: 'A distância entre os pontos A(1,2) e B(4,6) é:',
      alternativas: ['3', '4', '5', '6'],
      respostaCorreta: 2, // 5
      explicacao: 'd = √[(4-1)² + (6-2)²] = √[9 + 16] = √25 = 5',
      assunto: 'Geometria Analítica',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: 'em2_003',
      enunciado: 'Qual é o período da função f(x) = sen(2x)?',
      alternativas: ['π/2', 'π', '2π', '4π'],
      respostaCorreta: 1, // π
      explicacao:
          'Para f(x) = sen(kx), o período é 2π/k. Logo, período = 2π/2 = π',
      assunto: 'Funções trigonométricas',
      dificuldade: 3,
    ),
  ];

  /// Ensino Médio - 3º ano
  static final List<QuestaoDescoberta> _questoes3anoEM = [
    QuestaoDescoberta(
      id: 'em3_001',
      enunciado:
          'Um capital de R\$ 1000 aplicado a 10% ao ano em juros compostos. Qual o montante após 2 anos?',
      alternativas: ['R\$ 1200', 'R\$ 1210', 'R\$ 1100', 'R\$ 1150'],
      respostaCorreta: 1, // R$ 1210
      explicacao: 'M = C(1+i)ⁿ = 1000(1,1)² = 1000 × 1,21 = R\$ 1210',
      assunto: 'Matemática Financeira',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: 'em3_002',
      enunciado: 'O volume de um cone de raio 3 e altura 4 é:',
      alternativas: ['12π', '16π', '18π', '36π'],
      respostaCorreta: 0, // 12π
      explicacao: 'V = (1/3)πr²h = (1/3)π(3²)(4) = (1/3)π(9)(4) = 12π',
      assunto: 'Geometria Espacial',
      dificuldade: 2,
    ),
  ];

  /// ENEM Style - Questões interdisciplinares e contextualizadas
  static final List<QuestaoDescoberta> _questoesEnemStyle = [
    // QUESTÃO VISUAL - Desconto produto
    QuestaoDescoberta(
      id: 'enem_001_visual',
      enunciado:
          'Observe o cartaz promocional. Qual é o preço final do produto após aplicar o desconto?',
      alternativas: ['R\$ 60', 'R\$ 64', 'R\$ 72', 'R\$ 80'],
      respostaCorreta: 0, // R$ 60
      explicacao:
          'Preço original R\$ 80 com 25% de desconto: 80 - (80 × 0,25) = 80 - 20 = R\$ 60',
      assunto: 'Porcentagem',
      dificuldade: 2,
      imagemEspecifica:
          'assets/images/questoes/ensino-medio/em_001_desconto_produto.png',
    ),

    QuestaoDescoberta(
      id: 'enem_002',
      enunciado:
          'Uma empresa reduziu seus funcionários de 250 para 200. Qual foi o percentual de redução?',
      alternativas: ['15%', '20%', '25%', '30%'],
      respostaCorreta: 1, // 20%
      explicacao: 'Redução: (250-200)/250 × 100% = 50/250 × 100% = 20%',
      assunto: 'Porcentagem',
      dificuldade: 2,
    ),

    QuestaoDescoberta(
      id: 'enem_003',
      enunciado:
          'Uma escada de 5m está apoiada numa parede. Se a base fica a 3m da parede, qual a altura alcançada?',
      alternativas: ['3m', '4m', '5m', '6m'],
      respostaCorreta: 1, // 4m
      explicacao: 'Teorema de Pitágoras: h² = 5² - 3² = 25 - 9 = 16 → h = 4m',
      assunto: 'Teorema de Pitágoras',
      dificuldade: 3,
    ),

    QuestaoDescoberta(
      id: 'enem_004',
      enunciado:
          'Um carro faz 12 km com 1 litro. Para percorrer 180 km, quantos litros precisa?',
      alternativas: ['12', '15', '18', '20'],
      respostaCorreta: 1, // 15
      explicacao: '180 ÷ 12 = 15 litros',
      assunto: 'Razão e Proporção',
      dificuldade: 1,
    ),

    QuestaoDescoberta(
      id: 'enem_005',
      enunciado:
          'Se um item custa R\$ 120 à vista ou R\$ 130 em 2x sem juros, qual a diferença percentual?',
      alternativas: ['8,3%', '10%', '12%', '15%'],
      respostaCorreta: 0, // 8,3%
      explicacao: 'Diferença: (130-120)/120 × 100% = 10/120 × 100% = 8,3%',
      assunto: 'Porcentagem',
      dificuldade: 3,
    ),
  ];

  /// Método auxiliar para debug - lista todos os assuntos disponíveis
  static Map<String, int> getAssuntosPorNivel(EducationLevel nivel) {
    final questoes = getQuestoesPorNivel(nivel);
    final assuntos = <String, int>{};

    for (final questao in questoes) {
      assuntos[questao.assunto] = (assuntos[questao.assunto] ?? 0) + 1;
    }

    return assuntos;
  }

  /// Método para validação - verifica se todas as questões estão bem formadas
  static bool validarPool(EducationLevel nivel) {
    final questoes = getQuestoesPorNivel(nivel);

    // Verificar se tem pelo menos 5 questões
    if (questoes.length < 5) return false;

    // Verificar se todas as questões têm 4 alternativas
    for (final questao in questoes) {
      if (questao.alternativas.length != 4) return false;
      if (questao.respostaCorreta < 0 || questao.respostaCorreta > 3)
        return false;
      if (questao.enunciado.isEmpty || questao.explicacao.isEmpty) return false;
    }

    return true;
  }

  /// Estatísticas do pool completo
  static Map<String, dynamic> getEstatisticas() {
    final stats = <String, dynamic>{};

    for (final nivel in EducationLevel.values) {
      final questoes = getQuestoesPorNivel(nivel);
      final assuntos = getAssuntosPorNivel(nivel);

      stats[nivel.toString()] = {
        'total_questoes': questoes.length,
        'questoes_visuais':
            questoes.where((q) => q.imagemEspecifica != null).length,
        'assuntos': assuntos,
        'dificuldades': _contarDificuldades(questoes),
        'valido': validarPool(nivel),
      };
    }

    return stats;
  }

  static Map<int, int> _contarDificuldades(List<QuestaoDescoberta> questoes) {
    final dificuldades = <int, int>{1: 0, 2: 0, 3: 0};

    for (final questao in questoes) {
      dificuldades[questao.dificuldade] =
          (dificuldades[questao.dificuldade] ?? 0) + 1;
    }

    return dificuldades;
  }
}
