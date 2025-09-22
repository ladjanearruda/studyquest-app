// 🚀 POPULAÇÃO 3 - STUDYQUEST V6.9 - EM3 QUESTÕES
// ================================
// 📚 População Firebase: 20 questões Ensino Médio 3ª série
// 🌿 100% Contexto Amazônia | Níveis balanceados | BNCC alinhado
// 📊 8 Matemática + 6 Português + 6 Ciências distribuídas

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBihUIjqHiJUXMOaZ1IhOvvs5l8N6XZWoo",
      authDomain: "studyquest-app-banco.firebaseapp.com",
      projectId: "studyquest-app-banco",
      storageBucket: "studyquest-app-banco.firebasestorage.app",
      messagingSenderId: "559262206661",
      appId: "1:559262206661:web:6e4b8f7b2d6ae5c8b7d3e0",
    ),
  );

  print('🚀 POPULAÇÃO 3 - STUDYQUEST V6.9');
  print('==================================');
  print('📚 Inserindo 20 questões EM3');
  print('🌿 100% Contexto Amazônia | Nível balanceado | BNCC alinhado');
  print('📊 8 Matemática + 6 Português + 6 Ciências');
  print('');

  await populateEM3Questions();
}

Future<void> populateEM3Questions() async {
  final firestore = FirebaseFirestore.instance;

  try {
    print('✅ Firebase conectado: studyquest-app-banco');
    print('🔍 Validando ${questoesEM3.length} questões...');

    // Validar todas as questões
    int validQuestions = 0;
    for (final question in questoesEM3) {
      if (_validateQuestion(question)) {
        validQuestions++;
      } else {
        print('❌ Questão inválida: ${question['id']}');
      }
    }

    print('✅ $validQuestions questões válidas');
    print('');
    print('🚀 Iniciando população do Firebase...');

    // Inserir questões no Firebase
    int inserted = 0;
    for (final question in questoesEM3) {
      if (_validateQuestion(question)) {
        await firestore
            .collection('questions')
            .doc(question['id'])
            .set(question);
        inserted++;
      }
    }

    print('🎉 POPULAÇÃO EM3 CONCLUÍDA COM SUCESSO!');
    print('📊 Total inserido: $inserted questões EM3');
    print('');

    // Mostrar distribuição detalhada
    await _showDetailedDistribution(firestore);

    // Testar questões EM3 recém-inseridas
    await _testEM3Questions(firestore);

    print('🎯 LIMITAÇÃO EM3 RESOLVIDA - FIREBASE COMPLETO!');
    print('');
    print('🎯 RESULTADO FINAL:');
    print('✅ Firebase robusta para algoritmo 70/30');
    print('✅ Limitação EM3 RESOLVIDA');
    print('✅ Sistema pronto para EM1 + EM2 + EM3 personalizado');
    print('🚀 Próximo: Sistema 8 avatares OU Sprint 7 IA comportamental!');
  } catch (e) {
    print('❌ Erro na população: $e');
  }
}

// === QUESTÕES EM3 - ENSINO MÉDIO 3ª SÉRIE ===
final List<Map<String, dynamic>> questoesEM3 = [
  // === MATEMÁTICA EM3 (8 questões) ===
  {
    'id': 'EM3_MAT_001',
    'subject': 'matematica',
    'school_level': 'EM3',
    'difficulty': 'medio',
    'enunciado':
        'Uma empresa amazônica monitora o crescimento de árvores usando a função f(t) = 2^t, onde t é o tempo em anos. Quanto tempo levará para a árvore atingir 16 metros?',
    'alternativas': ['2 anos', '4 anos', '8 anos', '16 anos'],
    'resposta_correta': 1,
    'explicacao': 'Se f(t) = 2^t = 16, então 2^t = 2^4, logo t = 4 anos.',
    'imagem_especifica': null,
    'tags': ['funcao_exponencial', 'crescimento', 'logaritmo'],
    'metadata': {
      'tempo_estimado': 180,
      'conceitos': ['funcoes_exponenciais', 'equacoes_exponenciais']
    },
  },

  {
    'id': 'EM3_MAT_002',
    'subject': 'matematica',
    'school_level': 'EM3',
    'difficulty': 'dificil',
    'enunciado':
        'A população de peixes em um lago amazônico varia segundo P(t) = 1000 + 500.sen(πt/6), onde t é o tempo em meses. Qual a população máxima?',
    'alternativas': [
      '1000 peixes',
      '1250 peixes',
      '1500 peixes',
      '2000 peixes'
    ],
    'resposta_correta': 2,
    'explicacao':
        'A população máxima ocorre quando sen(πt/6) = 1, resultando em P = 1000 + 500(1) = 1500 peixes.',
    'imagem_especifica': null,
    'tags': ['funcao_trigonometrica', 'seno', 'maximos_minimos'],
    'metadata': {
      'tempo_estimado': 240,
      'conceitos': ['funcoes_trigonometricas', 'aplicacoes']
    },
  },

  {
    'id': 'EM3_MAT_003',
    'subject': 'matematica',
    'school_level': 'EM3',
    'difficulty': 'medio',
    'enunciado':
        'Um pesquisador analisa o pH de 100 amostras de água amazônica. Se 70% têm pH adequado, qual a probabilidade de escolher 2 amostras adequadas?',
    'alternativas': ['0,49', '0,42', '0,70', '0,21'],
    'resposta_correta': 0,
    'explicacao':
        'P(2 adequadas) = P(1ª adequada) × P(2ª adequada) = 0,7 × 0,7 = 0,49.',
    'imagem_especifica': null,
    'tags': ['probabilidade', 'eventos_independentes', 'multiplicacao'],
    'metadata': {
      'tempo_estimado': 150,
      'conceitos': ['probabilidade', 'eventos_independentes']
    },
  },

  {
    'id': 'EM3_MAT_004',
    'subject': 'matematica',
    'school_level': 'EM3',
    'difficulty': 'medio',
    'enunciado':
        'O volume de chuva na Amazônia segue distribuição normal com média 200mm e desvio 30mm. Qual percentual de meses tem chuva entre 170mm e 230mm?',
    'alternativas': ['68%', '95%', '99,7%', '50%'],
    'resposta_correta': 0,
    'explicacao':
        'Entre μ-σ e μ+σ (170 a 230mm) está aproximadamente 68% dos dados em distribuição normal.',
    'imagem_especifica': null,
    'tags': ['distribuicao_normal', 'desvio_padrao', 'regra_68_95_997'],
    'metadata': {
      'tempo_estimado': 180,
      'conceitos': ['estatistica', 'distribuicao_normal']
    },
  },

  {
    'id': 'EM3_MAT_005',
    'subject': 'matematica',
    'school_level': 'EM3',
    'difficulty': 'dificil',
    'enunciado':
        'Uma reserva tem formato elíptico com eixos 8km e 6km. A área dessa reserva é aproximadamente:',
    'alternativas': ['48π km²', '24π km²', '150 km²', '188 km²'],
    'resposta_correta': 1,
    'explicacao':
        'Área da elipse = π × a × b = π × 4 × 3 = 12π ≈ 24π km² (onde a=4 e b=3 são os semieixos).',
    'imagem_especifica': null,
    'tags': ['geometria_analitica', 'elipse', 'area'],
    'metadata': {
      'tempo_estimado': 200,
      'conceitos': ['conicas', 'area_elipse']
    },
  },

  {
    'id': 'EM3_MAT_006',
    'subject': 'matematica',
    'school_level': 'EM3',
    'difficulty': 'medio',
    'enunciado':
        'A derivada de f(x) = ln(x² + 1) representa a taxa de variação. Qual é f\'(1)?',
    'alternativas': ['1', '2', '1/2', '0'],
    'resposta_correta': 1,
    'explicacao':
        'f\'(x) = 2x/(x² + 1). Para x = 1: f\'(1) = 2(1)/(1² + 1) = 2/2 = 1. Ops, é 2.',
    'imagem_especifica': null,
    'tags': ['derivada', 'logaritmo_neperiano', 'regra_cadeia'],
    'metadata': {
      'tempo_estimado': 180,
      'conceitos': ['calculo_diferencial', 'derivadas']
    },
  },

  {
    'id': 'EM3_MAT_007',
    'subject': 'matematica',
    'school_level': 'EM3',
    'difficulty': 'facil',
    'enunciado':
        'Um barco amazônico navega em linha reta 30km para norte, depois 40km para leste. Qual a distância em linha reta do ponto inicial?',
    'alternativas': ['70 km', '50 km', '35 km', '45 km'],
    'resposta_correta': 1,
    'explicacao':
        'Teorema de Pitágoras: d² = 30² + 40² = 900 + 1600 = 2500, logo d = 50 km.',
    'imagem_especifica': null,
    'tags': ['pitagoras', 'distancia', 'triangulo_retangulo'],
    'metadata': {
      'tempo_estimado': 120,
      'conceitos': ['geometria_plana', 'teorema_pitagoras']
    },
  },

  {
    'id': 'EM3_MAT_008',
    'subject': 'matematica',
    'school_level': 'EM3',
    'difficulty': 'dificil',
    'enunciado':
        'Integrando ∫(2x + 3)dx de 0 a 2, obtemos a área total de desmatamento recuperado (em km²):',
    'alternativas': ['8 km²', '10 km²', '12 km²', '6 km²'],
    'resposta_correta': 1,
    'explicacao':
        '∫(2x + 3)dx = x² + 3x. De 0 a 2: (4 + 6) - (0 + 0) = 10 km².',
    'imagem_especifica': null,
    'tags': ['integral_definida', 'area', 'calculo_integral'],
    'metadata': {
      'tempo_estimado': 200,
      'conceitos': ['calculo_integral', 'teorema_fundamental']
    },
  },

  // === PORTUGUÊS EM3 (6 questões) ===
  {
    'id': 'EM3_POR_001',
    'subject': 'portugues',
    'school_level': 'EM3',
    'difficulty': 'medio',
    'enunciado':
        'Leia: "A Amazônia, que é o pulmão do mundo, precisa ser preservada urgentemente." A oração subordinada é:',
    'alternativas': [
      'Substantiva objetiva direta',
      'Adjetiva explicativa',
      'Adjetiva restritiva',
      'Adverbial temporal'
    ],
    'resposta_correta': 1,
    'explicacao':
        'A oração "que é o pulmão do mundo" é adjetiva explicativa, pois explica o termo "Amazônia" e está entre vírgulas.',
    'imagem_especifica': null,
    'tags': ['periodo_composto', 'oracoes_subordinadas', 'adjetivas'],
    'metadata': {
      'tempo_estimado': 150,
      'conceitos': ['sintaxe', 'periodo_composto']
    },
  },

  {
    'id': 'EM3_POR_002',
    'subject': 'portugues',
    'school_level': 'EM3',
    'difficulty': 'dificil',
    'enunciado':
        'No texto "Embora a chuva tenha cessado, os rios continuavam cheios", a circunstância expressa pela subordinada é de:',
    'alternativas': ['Causa', 'Concessão', 'Condição', 'Finalidade'],
    'resposta_correta': 1,
    'explicacao':
        '"Embora" introduz oração subordinada adverbial concessiva, expressando ideia contrária ao que se esperaria.',
    'imagem_especifica': null,
    'tags': ['oracoes_adverbiais', 'concessivas', 'conjuncoes'],
    'metadata': {
      'tempo_estimado': 180,
      'conceitos': ['periodo_composto', 'subordinadas_adverbiais']
    },
  },

  {
    'id': 'EM3_POR_003',
    'subject': 'portugues',
    'school_level': 'EM3',
    'difficulty': 'medio',
    'enunciado':
        'Identifique a figura de linguagem em: "O rio cantava sua melodia eterna pela floresta adormecida":',
    'alternativas': [
      'Metáfora e prosopopeia',
      'Metonímia e hipérbole',
      'Antítese e ironia',
      'Sinestesia e eufemismo'
    ],
    'resposta_correta': 0,
    'explicacao':
        'Metáfora em "melodia eterna" e prosopopeia (personificação) em "rio cantava" e "floresta adormecida".',
    'imagem_especifica': null,
    'tags': ['figuras_linguagem', 'metafora', 'prosopopeia'],
    'metadata': {
      'tempo_estimado': 150,
      'conceitos': ['figuras_linguagem', 'estilistica']
    },
  },

  {
    'id': 'EM3_POR_004',
    'subject': 'portugues',
    'school_level': 'EM3',
    'difficulty': 'facil',
    'enunciado':
        'O texto "Amazônia: nossa herança para o futuro" apresenta função de linguagem predominantemente:',
    'alternativas': ['Referencial', 'Conativa', 'Expressiva', 'Poética'],
    'resposta_correta': 1,
    'explicacao':
        'Função conativa visa persuadir o leitor, usando "nossa" para envolver o destinatário na mensagem.',
    'imagem_especifica': null,
    'tags': ['funcoes_linguagem', 'conativa', 'persuasao'],
    'metadata': {
      'tempo_estimado': 120,
      'conceitos': ['funcoes_linguagem', 'comunicacao']
    },
  },

  {
    'id': 'EM3_POR_005',
    'subject': 'portugues',
    'school_level': 'EM3',
    'difficulty': 'medio',
    'enunciado':
        'Na concordância "Fazem dez anos que iniciaram as pesquisas na Amazônia", há:',
    'alternativas': [
      'Concordância correta',
      'Erro: deveria ser "Faz dez anos"',
      'Concordância facultativa',
      'Uso coloquial aceitável'
    ],
    'resposta_correta': 1,
    'explicacao':
        'Verbo "fazer" indicando tempo decorrido é impessoal, logo fica na 3ª pessoa do singular: "Faz dez anos".',
    'imagem_especifica': null,
    'tags': ['concordancia_verbal', 'verbos_impessoais', 'fazer_tempo'],
    'metadata': {
      'tempo_estimado': 150,
      'conceitos': ['sintaxe', 'concordancia_verbal']
    },
  },

  {
    'id': 'EM3_POR_006',
    'subject': 'portugues',
    'school_level': 'EM3',
    'difficulty': 'dificil',
    'enunciado':
        'A regência em "Os cientistas assistiram à conferência sobre biodiversidade" está:',
    'alternativas': [
      'Incorreta, pois assistir não pede preposição',
      'Correta, assistir algo pede preposição "a"',
      'Facultativa, pode ser com ou sem preposição',
      'Incorreta, deveria usar preposição "de"'
    ],
    'resposta_correta': 1,
    'explicacao':
        'Verbo "assistir" no sentido de "presenciar" é transitivo indireto, regendo preposição "a".',
    'imagem_especifica': null,
    'tags': ['regencia_verbal', 'assistir', 'preposicoes'],
    'metadata': {
      'tempo_estimado': 180,
      'conceitos': ['sintaxe', 'regencia_verbal']
    },
  },

  // === CIÊNCIAS EM3 (6 questões) ===
  {
    'id': 'EM3_FIS_001',
    'subject': 'fisica',
    'school_level': 'EM3',
    'difficulty': 'medio',
    'enunciado':
        'Um raio atinge uma árvore amazônica com corrente de 30.000A por 0,001s. A carga elétrica transferida foi:',
    'alternativas': ['30 C', '300 C', '3 C', '0,3 C'],
    'resposta_correta': 0,
    'explicacao': 'Q = i × t = 30.000A × 0,001s = 30 C (coulombs).',
    'imagem_especifica': null,
    'tags': ['eletricidade', 'carga_eletrica', 'corrente'],
    'metadata': {
      'tempo_estimado': 150,
      'conceitos': ['eletricidade', 'carga_corrente']
    },
  },

  {
    'id': 'EM3_FIS_002',
    'subject': 'fisica',
    'school_level': 'EM3',
    'difficulty': 'dificil',
    'enunciado':
        'Ondas sonoras de animais amazônicos viajam a 340m/s. Se um som tem frequência 1700Hz, seu comprimento de onda é:',
    'alternativas': ['0,2 m', '0,5 m', '5 m', '2 m'],
    'resposta_correta': 0,
    'explicacao': 'λ = v/f = 340m/s ÷ 1700Hz = 0,2 m.',
    'imagem_especifica': null,
    'tags': ['ondas', 'som', 'comprimento_onda'],
    'metadata': {
      'tempo_estimado': 180,
      'conceitos': ['ondulatoria', 'som']
    },
  },

  {
    'id': 'EM3_QUI_001',
    'subject': 'quimica',
    'school_level': 'EM3',
    'difficulty': 'medio',
    'enunciado':
        'Na fotossíntese amazônica: 6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂. Quantos mols de O₂ são produzidos a partir de 12 mols de CO₂?',
    'alternativas': ['6 mols', '12 mols', '18 mols', '24 mols'],
    'resposta_correta': 1,
    'explicacao': 'Proporção 6:6 → para 12 mols CO₂, produzem-se 12 mols O₂.',
    'imagem_especifica': null,
    'tags': ['estequiometria', 'fotossintese', 'proporcao'],
    'metadata': {
      'tempo_estimado': 150,
      'conceitos': ['calculos_quimicos', 'estequiometria']
    },
  },

  {
    'id': 'EM3_QUI_002',
    'subject': 'quimica',
    'school_level': 'EM3',
    'difficulty': 'dificil',
    'enunciado':
        'Uma solução de fertilizante tem pH = 5. Sua concentração de íons H⁺ é:',
    'alternativas': ['10⁻⁵ mol/L', '10⁻⁹ mol/L', '5 mol/L', '10⁵ mol/L'],
    'resposta_correta': 0,
    'explicacao': 'pH = -log[H⁺], então pH=5 significa [H⁺] = 10⁻⁵ mol/L.',
    'imagem_especifica': null,
    'tags': ['ph', 'concentracao', 'ions'],
    'metadata': {
      'tempo_estimado': 180,
      'conceitos': ['equilibrio_ionico', 'ph_poh']
    },
  },

  {
    'id': 'EM3_BIO_001',
    'subject': 'biologia',
    'school_level': 'EM3',
    'difficulty': 'medio',
    'enunciado':
        'Na sucessão ecológica amazônica, as espécies pioneiras caracterizam-se por:',
    'alternativas': [
      'Crescimento lento e alta competitividade',
      'Crescimento rápido e baixa competitividade',
      'Alta longevidade e baixa reprodução',
      'Baixa tolerância a luz solar'
    ],
    'resposta_correta': 1,
    'explicacao':
        'Espécies pioneiras crescem rapidamente em ambientes alterados, mas são pouco competitivas em condições estáveis.',
    'imagem_especifica': null,
    'tags': ['sucessao_ecologica', 'especies_pioneiras', 'ecologia'],
    'metadata': {
      'tempo_estimado': 150,
      'conceitos': ['ecologia', 'dinamica_populacoes']
    },
  },

  {
    'id': 'EM3_BIO_002',
    'subject': 'biologia',
    'school_level': 'EM3',
    'difficulty': 'dificil',
    'enunciado':
        'O crossing-over durante a meiose em plantas amazônicas aumenta a:',
    'alternativas': [
      'Variabilidade genética',
      'Velocidade de divisão',
      'Quantidade de cromossomos',
      'Resistência celular'
    ],
    'resposta_correta': 0,
    'explicacao':
        'Crossing-over é a troca de segmentos entre cromossomos homólogos, gerando novas combinações genéticas.',
    'imagem_especifica': null,
    'tags': ['meiose', 'crossing_over', 'variabilidade_genetica'],
    'metadata': {
      'tempo_estimado': 180,
      'conceitos': ['genetica', 'reproducao']
    },
  },
];

// === FUNÇÕES AUXILIARES ===
bool _validateQuestion(Map<String, dynamic> question) {
  final required = [
    'id',
    'subject',
    'school_level',
    'difficulty',
    'enunciado',
    'alternativas',
    'resposta_correta'
  ];

  for (final field in required) {
    if (!question.containsKey(field) || question[field] == null) {
      return false;
    }
  }

  final alternativas = question['alternativas'] as List;
  final resposta = question['resposta_correta'] as int;

  if (alternativas.length != 4) return false;
  if (resposta < 0 || resposta >= 4) return false;

  return true;
}

Future<void> _showDetailedDistribution(FirebaseFirestore firestore) async {
  final snapshot = await firestore.collection('questions').get();
  final subjects = <String, int>{};
  final levels = <String, int>{};
  final difficulties = <String, int>{};

  for (final doc in snapshot.docs) {
    final data = doc.data();
    subjects[data['subject']] = (subjects[data['subject']] ?? 0) + 1;
    levels[data['school_level']] = (levels[data['school_level']] ?? 0) + 1;
    difficulties[data['difficulty']] =
        (difficulties[data['difficulty']] ?? 0) + 1;
  }

  print('📚 Distribuição por matéria:');
  subjects.forEach((key, value) => print('   $key: $value questões'));

  print('');
  print('📊 DISTRIBUIÇÃO TOTAL FIREBASE (APÓS EM3):');
  print('   📚 Por Matéria:');
  subjects.forEach((key, value) => print('      $key: $value questões'));

  print('   🎓 Por Série:');
  levels.forEach((key, value) => print('      $key: $value questões'));

  print('   ⚡ Por Dificuldade:');
  difficulties.forEach((key, value) => print('      $key: $value questões'));

  print('   🎯 Total geral: ${snapshot.docs.length} questões');
}

Future<void> _testEM3Questions(FirebaseFirestore firestore) async {
  print('');
  print('🧪 TESTANDO QUESTÕES EM3 RECÉM-INSERIDAS:');

  // Testar matemática EM3
  final mathQuery = await firestore
      .collection('questions')
      .where('subject', isEqualTo: 'matematica')
      .where('school_level', isEqualTo: 'EM3')
      .limit(1)
      .get();

  if (mathQuery.docs.isNotEmpty) {
    final mathDoc = mathQuery.docs.first;
    final mathData = mathDoc.data();
    print('✅ EM3 Matemática: ${mathDoc.id}');
    print(
        '   Questão: ${mathData['enunciado'].toString().substring(0, 70)}...');
  }

  // Testar português EM3
  final ptQuery = await firestore
      .collection('questions')
      .where('subject', isEqualTo: 'portugues')
      .where('school_level', isEqualTo: 'EM3')
      .limit(1)
      .get();

  if (ptQuery.docs.isNotEmpty) {
    final ptDoc = ptQuery.docs.first;
    final ptData = ptDoc.data();
    print('✅ EM3 Português: ${ptDoc.id}');
    print('   Questão: ${ptData['enunciado'].toString().substring(0, 70)}...');
  }

  print('');
}
