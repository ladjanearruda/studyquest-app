// lib/features/modo_descoberta/data/questoes_nivelamento.dart

import '../models/questao_descoberta.dart';
import '../../onboarding/screens/onboarding_screen.dart';

/// Sistema de pools de questões organizadas por nível escolar
/// Cada pool contém 10 questões para seleção aleatória de 5
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
    QuestaoDescoberta(
      id: '6ano_001',
      enunciado:
          'Na trilha da floresta, você encontra 3 grupos de macacos. Cada grupo tem 8 macacos. Quantos macacos você viu no total?',
      alternativas: ['21', '24', '32', '18'],
      respostaCorreta: 1, // 24
      explicacao: '3 grupos × 8 macacos = 24 macacos',
      assunto: 'Multiplicação',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: '6ano_002',
      enunciado:
          'Você precisa dividir 48 frutas igualmente entre 6 cestas. Quantas frutas vão em cada cesta?',
      alternativas: ['6', '8', '9', '7'],
      respostaCorreta: 1, // 8
      explicacao: '48 ÷ 6 = 8 frutas por cesta',
      assunto: 'Divisão',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: '6ano_003',
      enunciado:
          'Na sua mochila, 2/5 do espaço está ocupado com água. Que fração representa o espaço livre?',
      alternativas: ['2/5', '3/5', '1/5', '4/5'],
      respostaCorreta: 1, // 3/5
      explicacao: 'Se 2/5 está ocupado, então 5/5 - 2/5 = 3/5 está livre',
      assunto: 'Frações',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '6ano_004',
      enunciado:
          'Um retângulo tem 12 cm de comprimento e 8 cm de largura. Qual é sua área?',
      alternativas: ['40 cm²', '96 cm²', '20 cm²', '48 cm²'],
      respostaCorreta: 1, // 96
      explicacao: 'Área = comprimento × largura = 12 × 8 = 96 cm²',
      assunto: 'Geometria',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '6ano_005',
      enunciado:
          'Se você coleta 15 sementes por dia, quantas sementes terá em uma semana?',
      alternativas: ['75', '90', '105', '120'],
      respostaCorreta: 2, // 105
      explicacao: '15 sementes × 7 dias = 105 sementes',
      assunto: 'Multiplicação',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: '6ano_006',
      enunciado: 'Qual é o resultado de 789 + 456?',
      alternativas: ['1.245', '1.235', '1.255', '1.145'],
      respostaCorreta: 0, // 1.245
      explicacao: '789 + 456 = 1.245',
      assunto: 'Adição',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: '6ano_007',
      enunciado: 'Um triângulo tem todos os lados iguais. Como ele se chama?',
      alternativas: ['Isósceles', 'Escaleno', 'Equilátero', 'Retângulo'],
      respostaCorreta: 2, // Equilátero
      explicacao: 'Triângulo com todos os lados iguais é equilátero',
      assunto: 'Geometria',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '6ano_008',
      enunciado:
          'Se 1/4 das árvores da floresta são palmeiras e há 80 árvores, quantas são palmeiras?',
      alternativas: ['15', '20', '25', '30'],
      respostaCorreta: 1, // 20
      explicacao: '1/4 de 80 = 80 ÷ 4 = 20 palmeiras',
      assunto: 'Frações',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '6ano_009',
      enunciado: 'Quanto é 54 - 28?',
      alternativas: ['24', '26', '28', '22'],
      respostaCorreta: 1, // 26
      explicacao: '54 - 28 = 26',
      assunto: 'Subtração',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: '6ano_010',
      enunciado: 'Um quadrado tem lado de 9 cm. Qual é seu perímetro?',
      alternativas: ['18 cm', '36 cm', '81 cm', '27 cm'],
      respostaCorreta: 1, // 36
      explicacao: 'Perímetro = 4 × lado = 4 × 9 = 36 cm',
      assunto: 'Geometria',
      dificuldade: 2,
    ),
  ];

  /// 7º ano - Equações 1º grau, proporcionalidade, ângulos
  static final List<QuestaoDescoberta> _questoes7ano = [
    QuestaoDescoberta(
      id: '7ano_001',
      enunciado: 'Resolva a equação: x + 15 = 23',
      alternativas: ['6', '8', '10', '12'],
      respostaCorreta: 1, // 8
      explicacao: 'x = 23 - 15 = 8',
      assunto: 'Equações',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '7ano_002',
      enunciado: 'Se 3 garrafas custam R\$ 12, quanto custam 7 garrafas?',
      alternativas: ['R\$ 24', 'R\$ 28', 'R\$ 32', 'R\$ 21'],
      respostaCorreta: 1, // R$ 28
      explicacao: 'Regra de três: 3/12 = 7/x → x = 28',
      assunto: 'Proporcionalidade',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '7ano_003',
      enunciado:
          'Dois ângulos são complementares. Se um mede 35°, quanto mede o outro?',
      alternativas: ['45°', '55°', '65°', '145°'],
      respostaCorreta: 1, // 55°
      explicacao: 'Ângulos complementares somam 90°: 90° - 35° = 55°',
      assunto: 'Ângulos',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '7ano_004',
      enunciado: 'Qual é o valor de x na equação: 2x = 18?',
      alternativas: ['6', '9', '12', '15'],
      respostaCorreta: 1, // 9
      explicacao: 'x = 18 ÷ 2 = 9',
      assunto: 'Equações',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '7ano_005',
      enunciado:
          'Em uma receita para 4 pessoas usam-se 200g de açúcar. Para 10 pessoas, quantos gramas?',
      alternativas: ['400g', '500g', '600g', '800g'],
      respostaCorreta: 1, // 500g
      explicacao: 'Regra de três: 4/200 = 10/x → x = 500g',
      assunto: 'Proporcionalidade',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '7ano_006',
      enunciado: 'Resolva: 3x - 7 = 14',
      alternativas: ['5', '7', '9', '11'],
      respostaCorreta: 1, // 7
      explicacao: '3x = 14 + 7 = 21 → x = 21 ÷ 3 = 7',
      assunto: 'Equações',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '7ano_007',
      enunciado:
          'Dois ângulos são suplementares. Se um mede 110°, quanto mede o outro?',
      alternativas: ['70°', '80°', '90°', '60°'],
      respostaCorreta: 0, // 70°
      explicacao: 'Ângulos suplementares somam 180°: 180° - 110° = 70°',
      assunto: 'Ângulos',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '7ano_008',
      enunciado: 'Se 5 canetas custam R\$ 15, qual o preço unitário?',
      alternativas: ['R\$ 2', 'R\$ 3', 'R\$ 4', 'R\$ 5'],
      respostaCorreta: 1, // R$ 3
      explicacao: 'Preço unitário = 15 / 5 = R\$ 3',
      assunto: 'Proporcionalidade',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: '7ano_009',
      enunciado: 'Resolva: x/4 = 12',
      alternativas: ['3', '16', '48', '24'],
      respostaCorreta: 2, // 48
      explicacao: 'x = 12 × 4 = 48',
      assunto: 'Equações',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '7ano_010',
      enunciado: 'Um ângulo reto mede:',
      alternativas: ['45°', '90°', '180°', '360°'],
      respostaCorreta: 1, // 90°
      explicacao: 'Ângulo reto sempre mede 90°',
      assunto: 'Ângulos',
      dificuldade: 1,
    ),
  ];

  /// 8º ano - Sistemas de equações, teorema de Pitágoras, potências
  static final List<QuestaoDescoberta> _questoes8ano = [
    QuestaoDescoberta(
      id: '8ano_001',
      enunciado: 'Quanto é 2³ × 2²?',
      alternativas: ['2⁵', '2⁶', '4⁵', '8²'],
      respostaCorreta: 0, // 2⁵
      explicacao:
          'Na multiplicação de potências de mesma base: 2³ × 2² = 2³⁺² = 2⁵',
      assunto: 'Potências',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '8ano_002',
      enunciado:
          'Em um triângulo retângulo, os catetos medem 3 e 4. Quanto mede a hipotenusa?',
      alternativas: ['5', '6', '7', '25'],
      respostaCorreta: 0, // 5
      explicacao: 'Teorema de Pitágoras: h² = 3² + 4² = 9 + 16 = 25 → h = 5',
      assunto: 'Teorema de Pitágoras',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '8ano_003',
      enunciado: 'Resolva o sistema: x + y = 10 e x - y = 2',
      alternativas: ['x=6, y=4', 'x=5, y=5', 'x=7, y=3', 'x=8, y=2'],
      respostaCorreta: 0, // x=6, y=4
      explicacao:
          'Somando as equações: 2x = 12 → x = 6. Substituindo: 6 + y = 10 → y = 4',
      assunto: 'Sistemas',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '8ano_004',
      enunciado: 'Qual é o valor de (-3)²?',
      alternativas: ['-9', '9', '-6', '6'],
      respostaCorreta: 1, // 9
      explicacao: '(-3)² = (-3) × (-3) = 9 (negativo × negativo = positivo)',
      assunto: 'Potências',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '8ano_005',
      enunciado:
          'Um triângulo retângulo tem hipotenusa 13 e um cateto 5. Quanto mede o outro cateto?',
      alternativas: ['8', '12', '15', '18'],
      respostaCorreta: 1, // 12
      explicacao: 'c² = 13² - 5² = 169 - 25 = 144 → c = 12',
      assunto: 'Teorema de Pitágoras',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '8ano_006',
      enunciado: 'Quanto é 5⁰?',
      alternativas: ['0', '1', '5', 'Indefinido'],
      respostaCorreta: 1, // 1
      explicacao: 'Qualquer número (exceto 0) elevado à potência 0 é igual a 1',
      assunto: 'Potências',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '8ano_007',
      enunciado: 'Resolva o sistema: 2x + y = 7 e x - y = 2',
      alternativas: ['x=3, y=1', 'x=2, y=3', 'x=4, y=-1', 'x=1, y=5'],
      respostaCorreta: 0, // x=3, y=1
      explicacao: 'Somando: 3x = 9 → x = 3. Substituindo: 2(3) + y = 7 → y = 1',
      assunto: 'Sistemas',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '8ano_008',
      enunciado: 'Quanto é (2²)³?',
      alternativas: ['2⁵', '2⁶', '6²', '8'],
      respostaCorreta: 1, // 2⁶
      explicacao: 'Potência de potência: (2²)³ = 2²ˣ³ = 2⁶',
      assunto: 'Potências',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '8ano_009',
      enunciado: 'Um quadrado tem diagonal 5√2. Quanto mede seu lado?',
      alternativas: ['3', '4', '5', '6'],
      respostaCorreta: 2, // 5
      explicacao: 'Diagonal = lado × √2 → 5√2 = lado × √2 → lado = 5',
      assunto: 'Teorema de Pitágoras',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '8ano_010',
      enunciado: 'Resolva: 3x + 2y = 13 e x + y = 5',
      alternativas: ['x=3, y=2', 'x=2, y=3', 'x=4, y=1', 'x=1, y=4'],
      respostaCorreta: 0, // x=3, y=2
      explicacao:
          'Da 2ª: y = 5-x. Substituindo: 3x + 2(5-x) = 13 → x = 3, y = 2',
      assunto: 'Sistemas',
      dificuldade: 3,
    ),
  ];

  /// 9º ano - Funções 1º grau, probabilidade, trigonometria básica
  static final List<QuestaoDescoberta> _questoes9ano = [
    QuestaoDescoberta(
      id: '9ano_001',
      enunciado: 'A função f(x) = 2x + 3. Qual é o valor de f(5)?',
      alternativas: ['8', '10', '13', '15'],
      respostaCorreta: 2, // 13
      explicacao: 'f(5) = 2(5) + 3 = 10 + 3 = 13',
      assunto: 'Funções',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '9ano_002',
      enunciado:
          'Qual a probabilidade de tirar um número par ao lançar um dado?',
      alternativas: ['1/6', '1/3', '1/2', '2/3'],
      respostaCorreta: 2, // 1/2
      explicacao:
          'Números pares: 2, 4, 6. São 3 de 6 possibilidades = 3/6 = 1/2',
      assunto: 'Probabilidade',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '9ano_003',
      enunciado: 'Em um triângulo retângulo, sen(30°) é igual a:',
      alternativas: ['1/2', '√2/2', '√3/2', '1'],
      respostaCorreta: 0, // 1/2
      explicacao: 'O seno de 30° é sempre 1/2',
      assunto: 'Trigonometria',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '9ano_004',
      enunciado:
          'Uma função linear passa pelos pontos (0,2) e (1,5). Qual sua lei?',
      alternativas: [
        'f(x) = 3x + 2',
        'f(x) = 2x + 3',
        'f(x) = x + 5',
        'f(x) = 5x + 2'
      ],
      respostaCorreta: 0, // f(x) = 3x + 2
      explicacao: 'Coeficiente angular: (5-2)/(1-0) = 3. Coeficiente linear: 2',
      assunto: 'Funções',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '9ano_005',
      enunciado:
          'Numa urna há 5 bolas vermelhas e 3 azuis. Qual a probabilidade de tirar uma vermelha?',
      alternativas: ['3/8', '5/8', '3/5', '5/3'],
      respostaCorreta: 1, // 5/8
      explicacao: 'Total: 8 bolas. Vermelhas: 5. Probabilidade: 5/8',
      assunto: 'Probabilidade',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '9ano_006',
      enunciado: 'Quanto é cos(60°)?',
      alternativas: ['1/2', '√2/2', '√3/2', '1'],
      respostaCorreta: 0, // 1/2
      explicacao: 'O cosseno de 60° é sempre 1/2',
      assunto: 'Trigonometria',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '9ano_007',
      enunciado: 'Se f(x) = -2x + 4, qual é o zero da função?',
      alternativas: ['1', '2', '3', '4'],
      respostaCorreta: 1, // 2
      explicacao: 'Zero da função: -2x + 4 = 0 → 2x = 4 → x = 2',
      assunto: 'Funções',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '9ano_008',
      enunciado:
          'Lançando duas moedas, qual a probabilidade de sair duas caras?',
      alternativas: ['1/4', '1/3', '1/2', '2/3'],
      respostaCorreta: 0, // 1/4
      explicacao: 'Possibilidades: CC, CK, KC, KK. Duas caras: 1 de 4 = 1/4',
      assunto: 'Probabilidade',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '9ano_009',
      enunciado: 'Quanto é tg(45°)?',
      alternativas: ['1/2', '√2/2', '√3/3', '1'],
      respostaCorreta: 3, // 1
      explicacao: 'A tangente de 45° é sempre 1',
      assunto: 'Trigonometria',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '9ano_010',
      enunciado:
          'Uma função f(x) = ax + b tem f(0) = 3 e f(1) = 7. Qual é f(2)?',
      alternativas: ['9', '10', '11', '12'],
      respostaCorreta: 2, // 11
      explicacao:
          'f(x) = 4x + 3 (coef. angular = 4, linear = 3). f(2) = 4(2) + 3 = 11',
      assunto: 'Funções',
      dificuldade: 3,
    ),
  ];

  // ===== 📚 ENSINO MÉDIO =====

  /// 1º ano EM - Funções (1º e 2º grau), sequências, trigonometria
  static final List<QuestaoDescoberta> _questoes1anoEM = [
    QuestaoDescoberta(
      id: '1em_001',
      enunciado: 'A função f(x) = x² - 4x + 3 tem vértice em:',
      alternativas: ['(2, -1)', '(1, 0)', '(3, 0)', '(2, 1)'],
      respostaCorreta: 0, // (2, -1)
      explicacao: 'Vértice: x = -b/2a = 4/2 = 2. f(2) = 4 - 8 + 3 = -1',
      assunto: 'Função 2º grau',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '1em_002',
      enunciado: 'Na PA (3, 7, 11, 15, ...), qual é o 10º termo?',
      alternativas: ['37', '39', '41', '43'],
      respostaCorreta: 1, // 39
      explicacao: 'a₁ = 3, r = 4. a₁₀ = 3 + (10-1)×4 = 3 + 36 = 39',
      assunto: 'PA',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '1em_003',
      enunciado: 'Qual é o período da função f(x) = sen(2x)?',
      alternativas: ['π/2', 'π', '2π', '4π'],
      respostaCorreta: 1, // π
      explicacao: 'Período de sen(kx) é 2π/k = 2π/2 = π',
      assunto: 'Trigonometria',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '1em_004',
      enunciado: 'As raízes de x² - 5x + 6 = 0 são:',
      alternativas: ['2 e 3', '1 e 6', '-2 e -3', '0 e 5'],
      respostaCorreta: 0, // 2 e 3
      explicacao: 'Fatorando: (x-2)(x-3) = 0. Raízes: x = 2 e x = 3',
      assunto: 'Função 2º grau',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '1em_005',
      enunciado: 'Na PG (2, 6, 18, 54, ...), qual é a razão?',
      alternativas: ['2', '3', '4', '6'],
      respostaCorreta: 1, // 3
      explicacao: 'Razão = termo seguinte ÷ termo anterior = 6 ÷ 2 = 3',
      assunto: 'PG',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '1em_006',
      enunciado: 'O valor máximo da função f(x) = -x² + 4x - 3 é:',
      alternativas: ['-1', '0', '1', '3'],
      respostaCorreta: 2, // 1
      explicacao: 'Vértice em x = 2. f(2) = -4 + 8 - 3 = 1',
      assunto: 'Função 2º grau',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '1em_007',
      enunciado: 'Quantos termos tem a PA (5, 8, 11, ..., 50)?',
      alternativas: ['15', '16', '17', '18'],
      respostaCorreta: 1, // 16
      explicacao: 'aₙ = a₁ + (n-1)r → 50 = 5 + (n-1)3 → n = 16',
      assunto: 'PA',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '1em_008',
      enunciado: 'Se sen(x) = 3/5 e x está no 1º quadrante, quanto é cos(x)?',
      alternativas: ['3/5', '4/5', '5/3', '5/4'],
      respostaCorreta: 1, // 4/5
      explicacao: 'sen²x + cos²x = 1 → cos²x = 1 - 9/25 = 16/25 → cos(x) = 4/5',
      assunto: 'Trigonometria',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '1em_009',
      enunciado: 'O 5º termo da PG (1, 2, 4, 8, ...) é:',
      alternativas: ['16', '24', '32', '64'],
      respostaCorreta: 0, // 16
      explicacao: 'a₅ = a₁ × q⁴ = 1 × 2⁴ = 16',
      assunto: 'PG',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '1em_010',
      enunciado: 'A função f(x) = 2x - 3 é crescente porque:',
      alternativas: ['a > 0', 'b < 0', 'a < 0', 'b > 0'],
      respostaCorreta: 0, // a > 0
      explicacao:
          'Função linear é crescente quando coeficiente angular (a) > 0',
      assunto: 'Função 1º grau',
      dificuldade: 2,
    ),
  ];

  /// 2º ano EM - Logaritmos, trigonometria avançada, geometria analítica
  static final List<QuestaoDescoberta> _questoes2anoEM = [
    QuestaoDescoberta(
      id: '2em_001',
      enunciado: 'Quanto é log₂(8)?',
      alternativas: ['2', '3', '4', '8'],
      respostaCorreta: 1, // 3
      explicacao: 'log₂(8) = x → 2ˣ = 8 → 2ˣ = 2³ → x = 3',
      assunto: 'Logaritmos',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '2em_002',
      enunciado: 'A distância entre os pontos A(1,2) e B(4,6) é:',
      alternativas: ['3', '4', '5', '7'],
      respostaCorreta: 2, // 5
      explicacao: 'd = √[(4-1)² + (6-2)²] = √[9 + 16] = √25 = 5',
      assunto: 'Geometria Analítica',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '2em_003',
      enunciado: 'Se log(x) = 2, então x vale:',
      alternativas: ['10', '20', '100', '200'],
      respostaCorreta: 2, // 100
      explicacao: 'log(x) = 2 → x = 10² = 100',
      assunto: 'Logaritmos',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '2em_004',
      enunciado:
          'A equação da reta que passa por (0,3) com coeficiente angular 2 é:',
      alternativas: ['y = 2x + 3', 'y = 3x + 2', 'y = 2x - 3', 'y = x + 5'],
      respostaCorreta: 0, // y = 2x + 3
      explicacao: 'Forma: y = mx + b → y = 2x + 3',
      assunto: 'Geometria Analítica',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '2em_005',
      enunciado: 'Quanto é log₃(27)?',
      alternativas: ['2', '3', '9', '27'],
      respostaCorreta: 1, // 3
      explicacao: 'log₃(27) = x → 3ˣ = 27 → 3ˣ = 3³ → x = 3',
      assunto: 'Logaritmos',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '2em_006',
      enunciado: 'O ponto médio entre A(2,4) e B(8,2) é:',
      alternativas: ['(5,3)', '(4,2)', '(6,3)', '(3,5)'],
      respostaCorreta: 0, // (5,3)
      explicacao: 'Pm = ((2+8)/2, (4+2)/2) = (5,3)',
      assunto: 'Geometria Analítica',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '2em_007',
      enunciado: 'log(100) + log(1000) é igual a:',
      alternativas: ['3', '5', '30', '100'],
      respostaCorreta: 1, // 5
      explicacao: 'log(100) + log(1000) = 2 + 3 = 5',
      assunto: 'Logaritmos',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '2em_008',
      enunciado: 'A reta y = 3x - 2 tem coeficiente angular:',
      alternativas: ['3', '-2', '2', '-3'],
      respostaCorreta: 0, // 3
      explicacao: 'Na forma y = mx + b, m = 3 é o coeficiente angular',
      assunto: 'Geometria Analítica',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: '2em_009',
      enunciado: 'Se 2ˣ = 32, então x vale:',
      alternativas: ['4', '5', '6', '16'],
      respostaCorreta: 1, // 5
      explicacao: '2ˣ = 32 → 2ˣ = 2⁵ → x = 5',
      assunto: 'Logaritmos',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '2em_010',
      enunciado: 'A circunferência x² + y² = 25 tem raio:',
      alternativas: ['5', '10', '25', '50'],
      respostaCorreta: 0, // 5
      explicacao: 'x² + y² = r² → r² = 25 → r = 5',
      assunto: 'Geometria Analítica',
      dificuldade: 2,
    ),
  ];

  /// 3º ano EM - Matemática financeira, estatística, geometria espacial
  static final List<QuestaoDescoberta> _questoes3anoEM = [
    QuestaoDescoberta(
      id: '3em_001',
      enunciado:
          'Um capital de R\$ 1000 aplicado a 5% ao mês por 2 meses (juros simples) rende:',
      alternativas: ['R\$ 50', 'R\$ 100', 'R\$ 150', 'R\$ 200'],
      respostaCorreta: 1, // R$ 100
      explicacao: 'J = C × i × t = 1000 × 0,05 × 2 = 100',
      assunto: 'Matemática Financeira',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '3em_002',
      enunciado: 'O volume de um cubo de aresta 4 cm é:',
      alternativas: ['16 cm³', '48 cm³', '64 cm³', '128 cm³'],
      respostaCorreta: 2, // 64 cm³
      explicacao: 'V = a³ = 4³ = 64 cm³',
      assunto: 'Geometria Espacial',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: '3em_003',
      enunciado: 'A média aritmética de 5, 7, 8, 10, 15 é:',
      alternativas: ['8', '9', '10', '11'],
      respostaCorreta: 1, // 9
      explicacao: 'Média = (5+7+8+10+15)/5 = 45/5 = 9',
      assunto: 'Estatística',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: '3em_004',
      enunciado:
          'R\$ 2000 aplicados a 3% ao mês por 4 meses (juros compostos) resulta em:',
      alternativas: ['R\$ 2240', 'R\$ 2250', 'R\$ 2260', 'R\$ 2270'],
      respostaCorreta: 1, // R$ 2250 (aproximado)
      explicacao: 'M = C(1+i)ᵗ = 2000(1,03)⁴ ≈ 2250',
      assunto: 'Matemática Financeira',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '3em_005',
      enunciado: 'A área da superfície de um cubo de aresta 3 cm é:',
      alternativas: ['18 cm²', '36 cm²', '54 cm²', '72 cm²'],
      respostaCorreta: 2, // 54 cm²
      explicacao: 'Área = 6a² = 6 × 3² = 6 × 9 = 54 cm²',
      assunto: 'Geometria Espacial',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '3em_006',
      enunciado: 'A mediana do conjunto {3, 7, 5, 9, 4, 8, 6} é:',
      alternativas: ['5', '6', '7', '8'],
      respostaCorreta: 1, // 6
      explicacao: 'Ordenando: {3,4,5,6,7,8,9}. Mediana = termo central = 6',
      assunto: 'Estatística',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '3em_007',
      enunciado: 'Uma esfera de raio 3 cm tem volume:',
      alternativas: ['36π cm³', '27π cm³', '18π cm³', '12π cm³'],
      respostaCorreta: 0, // 36π cm³
      explicacao: 'V = (4/3)πr³ = (4/3)π(3³) = (4/3)π(27) = 36π cm³',
      assunto: 'Geometria Espacial',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '3em_008',
      enunciado:
          'A taxa equivalente a 12% ao ano em juros compostos mensais é aproximadamente:',
      alternativas: ['0,8%', '0,9%', '1,0%', '1,2%'],
      respostaCorreta: 1, // 0,9%
      explicacao: '(1+i)¹² = 1,12 → 1+i = ¹²√1,12 ≈ 1,009 → i ≈ 0,9%',
      assunto: 'Matemática Financeira',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: '3em_009',
      enunciado: 'O volume de um cilindro de raio 2 cm e altura 5 cm é:',
      alternativas: ['10π cm³', '20π cm³', '40π cm³', '50π cm³'],
      respostaCorreta: 1, // 20π cm³
      explicacao: 'V = πr²h = π(2²)(5) = π(4)(5) = 20π cm³',
      assunto: 'Geometria Espacial',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: '3em_010',
      enunciado: 'A moda do conjunto {2, 3, 3, 4, 4, 4, 5} é:',
      alternativas: ['2', '3', '4', '5'],
      respostaCorreta: 2, // 4
      explicacao: 'Moda = valor que mais se repete = 4 (aparece 3 vezes)',
      assunto: 'Estatística',
      dificuldade: 1,
    ),
  ];

  /// Ensino Médio Completo - ENEM Style (interdisciplinar)
  static final List<QuestaoDescoberta> _questoesEnemStyle = [
    QuestaoDescoberta(
      id: 'enem_001',
      enunciado:
          'Uma empresa precisa embalar 240 produtos em caixas que comportam 15 unidades cada. Para otimizar o transporte, quantas caixas serão necessárias?',
      alternativas: ['15', '16', '17', '18'],
      respostaCorreta: 1, // 16
      explicacao: '240 ÷ 15 = 16 caixas exatas',
      assunto: 'Aplicação Prática',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: 'enem_002',
      enunciado:
          'Um terreno retangular tem 30m de frente e 40m de fundo. Qual sua área em m²?',
      alternativas: ['70', '140', '1200', '2400'],
      respostaCorreta: 2, // 1200
      explicacao: 'Área = comprimento × largura = 30 × 40 = 1200 m²',
      assunto: 'Geometria Aplicada',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: 'enem_003',
      enunciado:
          'Uma receita para 6 pessoas usa 300g de farinha. Para 10 pessoas, quantos gramas?',
      alternativas: ['400g', '450g', '500g', '600g'],
      respostaCorreta: 2, // 500g
      explicacao: 'Regra de três: 6/300 = 10/x → x = 500g',
      assunto: 'Proporcionalidade',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: 'enem_004',
      enunciado:
          'Um investimento de R\$ 5000 rende 2% ao mês. Após 3 meses (juros simples), o valor será:',
      alternativas: ['R\$ 5200', 'R\$ 5300', 'R\$ 5400', 'R\$ 5500'],
      respostaCorreta: 1, // R$ 5300
      explicacao: 'J = 5000 × 0,02 × 3 = 300. Total = 5000 + 300 = 5300',
      assunto: 'Matemática Financeira',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: 'enem_005',
      enunciado:
          'Em uma pesquisa com 500 pessoas, 60% preferem produto A. Quantas pessoas preferem produto A?',
      alternativas: ['250', '300', '350', '400'],
      respostaCorreta: 1, // 300
      explicacao: '60% de 500 = 0,6 × 500 = 300 pessoas',
      assunto: 'Porcentagem',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: 'enem_006',
      enunciado:
          'Uma piscina de 8m × 5m × 1,5m de profundidade tem volume de quantos litros?',
      alternativas: ['40.000', '50.000', '60.000', '80.000'],
      respostaCorreta: 2, // 60.000
      explicacao: 'V = 8 × 5 × 1,5 = 60 m³ = 60.000 litros',
      assunto: 'Volume e Conversão',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: 'enem_007',
      enunciado:
          'Um produto custa R\$ 80 e tem desconto de 25%. Qual o preço final?',
      alternativas: ['R\$ 55', 'R\$ 60', 'R\$ 65', 'R\$ 70'],
      respostaCorreta: 1, // R$ 60
      explicacao: 'Desconto: 80 × 0,25 = 20. Preço final: 80 - 20 = 60',
      assunto: 'Porcentagem',
      dificuldade: 2,
    ),
    QuestaoDescoberta(
      id: 'enem_008',
      enunciado:
          'Uma escada de 5m está apoiada numa parede. Se a base fica a 3m da parede, qual a altura alcançada?',
      alternativas: ['3m', '4m', '5m', '6m'],
      respostaCorreta: 1, // 4m
      explicacao: 'Teorema de Pitágoras: h² = 5² - 3² = 25 - 9 = 16 → h = 4m',
      assunto: 'Teorema de Pitágoras',
      dificuldade: 3,
    ),
    QuestaoDescoberta(
      id: 'enem_009',
      enunciado:
          'Um carro faz 12 km com 1 litro. Para percorrer 180 km, quantos litros precisa?',
      alternativas: ['12', '15', '18', '20'],
      respostaCorreta: 1, // 15
      explicacao: '180 ÷ 12 = 15 litros',
      assunto: 'Razão e Proporção',
      dificuldade: 1,
    ),
    QuestaoDescoberta(
      id: 'enem_010',
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
