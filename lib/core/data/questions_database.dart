// lib/core/data/questions_database.dart
import '../models/question_model.dart';

class QuestionsDatabase {
  /// Buscar questões por nível escolar
  static List<QuestionModel> getQuestionsByLevel(String schoolLevel,
      {int limit = 20}) {
    return _allQuestions
        .where((data) => data['school_level'] == schoolLevel)
        .take(limit)
        .map((data) => QuestionModel.createLocal(
              id: data['id'] as String,
              subject: data['subject'] as String,
              schoolLevel: data['school_level'] as String,
              difficulty: data['difficulty'] as String,
              enunciado: data['enunciado'] as String,
              alternativas: List<String>.from(data['alternativas'] as List),
              respostaCorreta: data['resposta_correta'] as int,
              explicacao: data['explicacao'] as String,
              aventuraContexto: data['aventura_contexto'] as String,
              personagemSituacao: data['personagem_situacao'] as String,
              localFloresta: data['local_floresta'] as String,
              aspectoComportamental: data['aspecto_comportamental'] as String,
              estiloAprendizado: data['estilo_aprendizado'] as String,
              imagemEspecifica: data['imagem_especifica'] as String?,
              tags: List<String>.from(data['tags'] ?? []),
              metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
            ))
        .toList();
  }

  /// Buscar questões por matéria
  static List<QuestionModel> getQuestionsBySubject(String subject,
      {int limit = 10}) {
    return _allQuestions
        .where((data) => data['subject'] == subject)
        .take(limit)
        .map((data) => QuestionModel.createLocal(
              id: data['id'] as String,
              subject: data['subject'] as String,
              schoolLevel: data['school_level'] as String,
              difficulty: data['difficulty'] as String,
              enunciado: data['enunciado'] as String,
              alternativas: List<String>.from(data['alternativas'] as List),
              respostaCorreta: data['resposta_correta'] as int,
              explicacao: data['explicacao'] as String,
              aventuraContexto: data['aventura_contexto'] as String,
              personagemSituacao: data['personagem_situacao'] as String,
              localFloresta: data['local_floresta'] as String,
              aspectoComportamental: data['aspecto_comportamental'] as String,
              estiloAprendizado: data['estilo_aprendizado'] as String,
              imagemEspecifica: data['imagem_especifica'] as String?,
              tags: List<String>.from(data['tags'] ?? []),
              metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
            ))
        .toList();
  }

  /// Estatísticas das questões disponíveis
  static Map<String, dynamic> getStats() {
    final stats = {
      'total': _allQuestions.length,
      'por_materia': <String, int>{},
      'por_nivel': <String, int>{},
      'por_dificuldade': <String, int>{},
    };

    for (final question in _allQuestions) {
      final subject = question['subject'] as String;
      final level = question['school_level'] as String;
      final difficulty = question['difficulty'] as String;

      // CORREÇÃO COMPLETA PARA TODAS AS TRÊS LINHAS
      final porMateria = stats['por_materia'] as Map<String, int>;
      final porNivel = stats['por_nivel'] as Map<String, int>;
      final porDificuldade = stats['por_dificuldade'] as Map<String, int>;

      porMateria[subject] = (porMateria[subject] ?? 0) + 1;
      porNivel[level] = (porNivel[level] ?? 0) + 1;
      porDificuldade[difficulty] = (porDificuldade[difficulty] ?? 0) + 1;
    }

    return stats;
  }

  /// Validar se todas as questões estão corretas
  static bool validateAllQuestions() {
    print('🔍 Validando ${_allQuestions.length} questões aventura floresta...');

    int valid = 0;
    int invalid = 0;

    for (final question in _allQuestions) {
      if (_validateQuestion(question)) {
        valid++;
      } else {
        invalid++;
      }
    }

    print('✅ $valid questões válidas');
    if (invalid > 0) {
      print('❌ $invalid questões inválidas');
    }

    return invalid == 0;
  }

  static bool _validateQuestion(Map<String, dynamic> question) {
    final required = [
      'id',
      'subject',
      'school_level',
      'difficulty',
      'enunciado',
      'alternativas',
      'resposta_correta',
      'aventura_contexto',
      'personagem_situacao',
      'local_floresta'
    ];

    for (final field in required) {
      if (!question.containsKey(field) || question[field] == null) {
        print(
            '❌ Questão ${question['id'] ?? 'sem ID'} inválida: campo $field ausente');
        return false;
      }
    }

    final alternativas = question['alternativas'] as List;
    final resposta = question['resposta_correta'] as int;

    if (alternativas.length != 4) {
      print('❌ Questão ${question['id']} deve ter exatamente 4 alternativas');
      return false;
    }

    if (resposta < 0 || resposta >= alternativas.length) {
      print(
          '❌ Questão ${question['id']} tem resposta_correta inválida: $resposta');
      return false;
    }

    return true;
  }

  /// Buscar questões para teste rápido
  static List<QuestionModel> getTestQuestions({int limit = 5}) {
    return getQuestionsByLevel('8ano', limit: limit);
  }

  // BANCO DE QUESTÕES AVENTURA NA FLORESTA AMAZÔNICA
  static final List<Map<String, dynamic>> _allQuestions = [
    {
      'id': 'floresta_mat_001',
      'subject': 'matematica',
      'school_level': '8ano',
      'difficulty': 'medio',
      'enunciado':
          '''🧭 Você está perdido na floresta amazônica e precisa atravessar um rio perigoso!

Observando do alto de uma árvore, você vê que o rio forma um retângulo de 150 metros de comprimento por 80 metros de largura.

Para economizar energia e não atrair jacarés, qual é a MENOR distância que você pode nadar?''',
      'alternativas': [
        'A) 150 metros (comprimento total)',
        'B) 80 metros (largura total)',
        'C) 115 metros (diagonal)',
        'D) 230 metros (contornando)'
      ],
      'resposta_correta': 1,
      'explicacao': '''🎯 Resposta: B) 80 metros

🧭 Para atravessar um rio retangular, a menor distância é sempre a largura, nadando perpendicularmente às margens.

🐊 Nadar na diagonal ou pelo comprimento seria mais perigoso e cansativo!''',
      'aventura_contexto': 'navegacao_rio',
      'personagem_situacao': 'explorador_perdido',
      'local_floresta': 'margem_rio',
      'aspecto_comportamental': 'foco_concentracao',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['geometria', 'area_perimetro', 'aplicacao_pratica'],
      'metadata': {'duracao_estimada': 90, 'dificuldade_numerica': 6},
    },
    {
      'id': 'floresta_mat_002',
      'subject': 'matematica',
      'school_level': '6ano',
      'difficulty': 'facil',
      'enunciado':
          '''🥤 Você encontrou água potável! Sua cantil comporta 2 litros.

Você bebeu 1/4 da capacidade para se hidratar, encheu a cantil e bebeu mais 1/2 litro.

Quantos litros restaram?''',
      'alternativas': [
        'A) 1,0 litro',
        'B) 1,5 litro',
        'C) 0,5 litro',
        'D) 2,0 litros'
      ],
      'resposta_correta': 1,
      'explicacao': '''🎯 Resposta: B) 1,5 litro

💧 Cálculo: Bebeu 1/4 de 2L = 0,5L + encheu (2L) - bebeu 0,5L = 1,5L restaram

Agora você tem água para continuar a aventura!''',
      'aventura_contexto': 'sobrevivencia',
      'personagem_situacao': 'explorador_perdido',
      'local_floresta': 'fonte_agua',
      'aspecto_comportamental': 'organizacao_planejamento',
      'estilo_aprendizado': 'pratico',
      'imagem_especifica': null,
      'tags': ['fracoes', 'aplicacao_pratica', 'operacoes_basicas'],
      'metadata': {'duracao_estimada': 75, 'dificuldade_numerica': 4},
    },
    {
      'id': 'floresta_mat_003',
      'subject': 'matematica',
      'school_level': '7ano',
      'difficulty': 'facil',
      'enunciado':
          '''🐦 Observando os pássaros da copa das árvores, você conta 15 tucanos em uma árvore e o dobro dessa quantidade em outra árvore próxima.

Quantos tucanos você observou no total?''',
      'alternativas': [
        'A) 30 tucanos',
        'B) 45 tucanos',
        'C) 25 tucanos',
        'D) 35 tucanos'
      ],
      'resposta_correta': 1,
      'explicacao': '''🎯 Resposta: B) 45 tucanos

🐦 Cálculo: 15 tucanos + (15 × 2) = 15 + 30 = 45 tucanos total.

Uma excelente observação da biodiversidade amazônica!''',
      'aventura_contexto': 'observacao_fauna',
      'personagem_situacao': 'biologa_pesquisando',
      'local_floresta': 'copa_arvores',
      'aspecto_comportamental': 'atencao_detalhes',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['multiplicacao', 'adicao', 'operacoes_basicas'],
      'metadata': {'duracao_estimada': 45, 'dificuldade_numerica': 3},
    },
    {
      'id': 'floresta_bio_001',
      'subject': 'biologia',
      'school_level': '7ano',
      'difficulty': 'facil',
      'enunciado':
          '''🌱 Durante sua exploração, você encontra uma planta medicinal! Suas folhas liberam um gel quando amassadas.

O guia explica que ela produz energia através da fotossíntese, usando luz solar.

Qual gás a planta ABSORVE durante esse processo?''',
      'alternativas': [
        'A) Oxigênio (O₂)',
        'B) Nitrogênio (N₂)',
        'C) Gás carbônico (CO₂)',
        'D) Vapor de água (H₂O)'
      ],
      'resposta_correta': 2,
      'explicacao': '''🎯 Resposta: C) Gás carbônico (CO₂)

🌱 Na fotossíntese: CO₂ + água + luz solar = glicose + oxigênio

Por isso a Amazônia é o "pulmão do mundo" - absorve CO₂ e produz O₂!''',
      'aventura_contexto': 'sobrevivencia',
      'personagem_situacao': 'biologa_pesquisando',
      'local_floresta': 'trilha_mata',
      'aspecto_comportamental': 'curiosidade_investigacao',
      'estilo_aprendizado': 'pratico',
      'imagem_especifica': null,
      'tags': ['fotossintese', 'plantas', 'gases', 'ecologia'],
      'metadata': {'duracao_estimada': 60, 'dificuldade_numerica': 3},
    },
    {
      'id': 'floresta_bio_002',
      'subject': 'biologia',
      'school_level': '6ano',
      'difficulty': 'facil',
      'enunciado':
          '''🐆 Você avista uma onça-pintada! Este grande felino é um predador que caça outros animais.

Na cadeia alimentar da floresta, qual posição a onça-pintada ocupa?''',
      'alternativas': [
        'A) Produtor primário',
        'B) Consumidor primário',
        'C) Consumidor secundário/terciário',
        'D) Decompositor'
      ],
      'resposta_correta': 2,
      'explicacao': '''🎯 Resposta: C) Consumidor secundário/terciário

🐆 A onça é um carnívoro no topo da cadeia - come outros carnívoros e herbívoros.

Ela controla o equilíbrio populacional na floresta!''',
      'aventura_contexto': 'observacao_fauna',
      'personagem_situacao': 'biologa_pesquisando',
      'local_floresta': 'trilha_mata',
      'aspecto_comportamental': 'curiosidade_investigacao',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['cadeia_alimentar', 'ecologia', 'carnivoros'],
      'metadata': {'duracao_estimada': 60, 'dificuldade_numerica': 2},
    },
    {
      'id': 'floresta_port_001',
      'subject': 'portugues',
      'school_level': '8ano',
      'difficulty': 'medio',
      'enunciado': '''📜 Você encontra um bilhete de outro explorador:

"A floresta sussurra seus segredos para quem sabe escutar..."

Que recurso de linguagem foi usado em "A floresta sussurra"?''',
      'alternativas': [
        'A) Metáfora (comparação implícita)',
        'B) Personificação (dar vida ao objeto)',
        'C) Hipérbole (exagero)',
        'D) Onomatopeia (som)'
      ],
      'resposta_correta': 1,
      'explicacao': '''🎯 Resposta: B) Personificação

📝 "Sussurrar" é ação humana atribuída à floresta (personificação).

Isso cria conexão emocional com a natureza!''',
      'aventura_contexto': 'descoberta_pistas',
      'personagem_situacao': 'explorador_estudioso',
      'local_floresta': 'acampamento_abandonado',
      'aspecto_comportamental': 'criatividade_expressao',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['figuras_linguagem', 'personificacao'],
      'metadata': {'duracao_estimada': 90, 'dificuldade_numerica': 5},
    },
    {
      'id': 'floresta_port_002',
      'subject': 'portugues',
      'school_level': '7ano',
      'difficulty': 'facil',
      'enunciado':
          '''📢 Na frase "Um bando de macacos-prego brincava entre as árvores", a palavra "bando" é:''',
      'alternativas': [
        'A) Substantivo comum',
        'B) Substantivo coletivo',
        'C) Adjetivo',
        'D) Verbo'
      ],
      'resposta_correta': 1,
      'explicacao': '''🎯 Resposta: B) Substantivo coletivo

📢 "Bando" indica conjunto de animais (substantivo coletivo).

Outros exemplos: cardume (peixes), matilha (cães), etc.''',
      'aventura_contexto': 'observacao_fauna',
      'personagem_situacao': 'biologa_pesquisando',
      'local_floresta': 'copa_arvores',
      'aspecto_comportamental': 'atencao_detalhes',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['substantivos', 'coletivos', 'classificacao'],
      'metadata': {'duracao_estimada': 70, 'dificuldade_numerica': 2},
    },
    {
      'id': 'floresta_geo_001',
      'subject': 'geografia',
      'school_level': '9ano',
      'difficulty': 'dificil',
      'enunciado': '''🧭 Seu GPS mostra: 3°S, 60°W

Analisando essas coordenadas, você está em qual localização?''',
      'alternativas': [
        'A) Hemisfério Norte e Leste de Greenwich',
        'B) Hemisfério Sul e Oeste de Greenwich',
        'C) Hemisfério Norte e Oeste de Greenwich',
        'D) Hemisfério Sul e Leste de Greenwich'
      ],
      'resposta_correta': 1,
      'explicacao': '''🎯 Resposta: B) Hemisfério Sul e Oeste de Greenwich

🌍 3°S = 3 graus ao Sul (hemisfério Sul)
60°W = 60 graus a Oeste de Greenwich

Você está no coração da Amazônia brasileira!''',
      'aventura_contexto': 'navegacao_orientacao',
      'personagem_situacao': 'explorador_experiente',
      'local_floresta': 'centro_floresta',
      'aspecto_comportamental': 'raciocinio_logico',
      'estilo_aprendizado': 'teorico',
      'imagem_especifica': null,
      'tags': ['coordenadas_geograficas', 'orientacao', 'hemisferios'],
      'metadata': {'duracao_estimada': 120, 'dificuldade_numerica': 7},
    },
    {
      'id': 'floresta_geo_002',
      'subject': 'geografia',
      'school_level': '6ano',
      'difficulty': 'facil',
      'enunciado':
          '''🌡️ Durante sua expedição, você nota que a temperatura varia pouco durante o dia, sempre entre 24°C e 32°C.

Esta característica indica que você está em qual tipo de clima?''',
      'alternativas': [
        'A) Clima temperado',
        'B) Clima equatorial',
        'C) Clima tropical seco',
        'D) Clima subtropical'
      ],
      'resposta_correta': 1,
      'explicacao': '''🎯 Resposta: B) Clima equatorial

🌿 Clima equatorial: temperaturas altas e constantes (24-32°C), pouca variação diária.

Típico da Amazônia, com chuvas frequentes e alta umidade!''',
      'aventura_contexto': 'observacao_clima',
      'personagem_situacao': 'explorador_cientista',
      'local_floresta': 'centro_floresta',
      'aspecto_comportamental': 'observacao_cientifica',
      'estilo_aprendizado': 'pratico',
      'imagem_especifica': null,
      'tags': ['tipos_clima', 'clima_equatorial', 'amazonia'],
      'metadata': {'duracao_estimada': 50, 'dificuldade_numerica': 3},
    },
    {
      'id': 'floresta_hist_001',
      'subject': 'historia',
      'school_level': '8ano',
      'difficulty': 'medio',
      'enunciado':
          '''🏺 Explorando uma área da floresta, você encontra vestígios de cerâmica com desenhos geométricos complexos.

Estes achados arqueológicos comprovam que antes da chegada dos europeus ao Brasil:''',
      'alternativas': [
        'A) A região era desabitada',
        'B) Existiam sociedades complexas na Amazônia',
        'C) Apenas grupos nômades viviam na floresta',
        'D) A cerâmica foi trazida pelos portugueses'
      ],
      'resposta_correta': 1,
      'explicacao': '''🎯 Resposta: B) Existiam sociedades complexas na Amazônia

🏺 Sítios arqueológicos na Amazônia revelam civilizações avançadas pré-colombianas.

A cerâmica marajoara e outras culturas mostram sociedades com milhares de anos!''',
      'aventura_contexto': 'descoberta_arqueologica',
      'personagem_situacao': 'arqueologo_explorador',
      'local_floresta': 'sitio_arqueologico',
      'aspecto_comportamental': 'curiosidade_investigacao',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['historia_brasil', 'povos_indigenas', 'arqueologia'],
      'metadata': {'duracao_estimada': 90, 'dificuldade_numerica': 5},
    },
    {
      'id': 'floresta_fis_001',
      'subject': 'fisica',
      'school_level': '9ano',
      'difficulty': 'dificil',
      'enunciado':
          '''🔊 Na floresta densa, o som viaja aproximadamente 340 m/s. 

Se você gritar e ouvir o eco após 3 segundos, qual a distância aproximada até a árvore que refletiu o som?''',
      'alternativas': [
        'A) 340 metros',
        'B) 510 metros',
        'C) 680 metros',
        'D) 1.020 metros'
      ],
      'resposta_correta': 1,
      'explicacao': '''🎯 Resposta: B) 510 metros

🔊 O som percorre ida e volta em 3s. Distância = (340 × 3) ÷ 2 = 510 metros.

O som vai até a árvore e volta, por isso dividimos por 2!''',
      'aventura_contexto': 'navegacao_orientacao',
      'personagem_situacao': 'explorador_perdido',
      'local_floresta': 'floresta_densa',
      'aspecto_comportamental': 'raciocinio_logico',
      'estilo_aprendizado': 'pratico',
      'imagem_especifica': null,
      'tags': ['ondas_sonoras', 'velocidade', 'eco'],
      'metadata': {'duracao_estimada': 180, 'dificuldade_numerica': 7},
    },
    {
      'id': 'floresta_qui_001',
      'subject': 'quimica',
      'school_level': '9ano',
      'difficulty': 'medio',
      'enunciado':
          '''🌧️ Você testa a água de um igarapé e descobre que tem pH 4,5 (solo amazônico é naturalmente ácido).

Isso significa que há maior concentração de:''',
      'alternativas': [
        'A) Íons OH⁻ (hidroxila)',
        'B) Íons H⁺ (hidrogênio)',
        'C) Água neutra',
        'D) Sais minerais'
      ],
      'resposta_correta': 1,
      'explicacao': '''🎯 Resposta: B) Íons H⁺ (hidrogênio)

🌧️ pH abaixo de 7 = ácido = mais íons H⁺

O solo amazônico é naturalmente ácido devido à decomposição orgânica!''',
      'aventura_contexto': 'analise_agua',
      'personagem_situacao': 'biologa_pesquisando',
      'local_floresta': 'igarape',
      'aspecto_comportamental': 'observacao_cientifica',
      'estilo_aprendizado': 'pratico',
      'imagem_especifica': null,
      'tags': ['ph', 'acidez', 'ions'],
      'metadata': {'duracao_estimada': 150, 'dificuldade_numerica': 4},
    },
  ];
}
