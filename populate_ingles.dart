import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔥 POPULAÇÃO FIREBASE - FASE 1 INGLÊS');
  print('======================================');
  
  final projectId = 'studyquest-app-banco';
  final baseUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';
  
  int sucesso = 0;
  int falha = 0;
  
  for (final q in questoesIngles) {
    try {
      final url = '$baseUrl/questions/${q['id']}';
      
      // Extrair metadata com cast explícito
      final meta = q['metadata'] as Map<String, dynamic>;
      final conceitos = meta['conceitos'] as List<dynamic>;
      
      final body = {
        'fields': {
          'subject': {'stringValue': q['subject']},
          'school_level': {'stringValue': q['school_level']},
          'difficulty': {'stringValue': q['difficulty']},
          'theme': {'stringValue': 'floresta'},
          'enunciado': {'stringValue': q['enunciado']},
          'alternativas': {
            'arrayValue': {
              'values': (q['alternativas'] as List)
                  .map((alt) => {'stringValue': alt})
                  .toList()
            }
          },
          'resposta_correta': {'integerValue': q['resposta_correta'].toString()},
          'explicacao': {'stringValue': q['explicacao']},
          'imagem_especifica': {'nullValue': null},
          'tags': {
            'arrayValue': {
              'values': (q['tags'] as List)
                  .map((tag) => {'stringValue': tag})
                  .toList()
            }
          },
          'metadata': {
            'mapValue': {
              'fields': {
                'tempo_estimado': {
                  'integerValue': meta['tempo_estimado'].toString()
                },
                'conceitos': {
                  'arrayValue': {
                    'values': conceitos.map((c) => {'stringValue': c}).toList()
                  }
                }
              }
            }
          }
        }
      };
      
      final request = await HttpClient().patchUrl(Uri.parse(url));
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(body));
      
      final response = await request.close();
      
      if (response.statusCode == 200) {
        sucesso++;
        if (sucesso % 5 == 0) print('📦 Progresso: $sucesso/30');
      } else {
        falha++;
        print('❌ ${q['id']} (${response.statusCode})');
      }
      
      await response.drain();
      await Future.delayed(Duration(milliseconds: 100));
      
    } catch (e) {
      falha++;
      print('❌ ${q['id']}: $e');
    }
  }
  
  print('');
  print('🎉 CONCLUÍDO!');
  print('✅ Sucesso: $sucesso');
  if (falha > 0) print('❌ Falhas: $falha');
  print('📊 Firebase: 122 → ${122 + sucesso}');
}

final questoesIngles = [
  {'id': 'ing_6ano_001_vocabulary_forest', 'subject': 'ingles', 'school_level': '6ano', 'difficulty': 'facil', 'enunciado': 'What is the English word for "floresta"?', 'alternativas': ['Forest', 'Flower', 'Floor', 'Fruit'], 'resposta_correta': 0, 'explicacao': '"Forest" é a tradução correta de floresta em inglês.', 'tags': ['vocabulary', 'nature', 'basic_words'], 'metadata': {'tempo_estimado': 60, 'conceitos': ['vocabulary']}},
  {'id': 'ing_6ano_002_animals_vocabulary', 'subject': 'ingles', 'school_level': '6ano', 'difficulty': 'facil', 'enunciado': 'Which animal lives in the Amazon rainforest? Choose the correct translation: "Onça-pintada"', 'alternativas': ['Tiger', 'Leopard', 'Jaguar', 'Lion'], 'resposta_correta': 2, 'explicacao': 'Jaguar é o nome em inglês para onça-pintada.', 'tags': ['animals', 'vocabulary', 'amazon_fauna'], 'metadata': {'tempo_estimado': 70, 'conceitos': ['animals_vocabulary']}},
  {'id': 'ing_6ano_003_colors_nature', 'subject': 'ingles', 'school_level': '6ano', 'difficulty': 'facil', 'enunciado': 'Complete: "The Amazon rainforest is very _____ because of all the trees."', 'alternativas': ['blue', 'green', 'red', 'yellow'], 'resposta_correta': 1, 'explicacao': '"Green" (verde) é a cor correta, pois a floresta tem muitas árvores.', 'tags': ['colors', 'adjectives', 'nature_description'], 'metadata': {'tempo_estimado': 60, 'conceitos': ['colors', 'adjectives']}},
  {'id': 'ing_6ano_004_numbers_trees', 'subject': 'ingles', 'school_level': '6ano', 'difficulty': 'facil', 'enunciado': 'Read: "There are THREE HUNDRED species of trees in one hectare of Amazon forest." How do we write 300?', 'alternativas': ['Three hundred', 'Three thousands', 'Thirty', 'Three hundredth'], 'resposta_correta': 0, 'explicacao': 'Three hundred é a forma correta de escrever 300 em inglês.', 'tags': ['numbers', 'reading', 'amazon_facts'], 'metadata': {'tempo_estimado': 80, 'conceitos': ['numbers', 'reading_comprehension']}},
  {'id': 'ing_6ano_005_simple_present', 'subject': 'ingles', 'school_level': '6ano', 'difficulty': 'medio', 'enunciado': 'Complete with the correct verb: "Trees _____ oxygen for us to breathe."', 'alternativas': ['produce', 'produces', 'producing', 'produced'], 'resposta_correta': 0, 'explicacao': 'Simple Present com sujeito plural (trees) usa verbo sem "s": produce.', 'tags': ['simple_present', 'plural_subject', 'verbs'], 'metadata': {'tempo_estimado': 90, 'conceitos': ['simple_present']}},
  {'id': 'ing_7ano_006_simple_past', 'subject': 'ingles', 'school_level': '7ano', 'difficulty': 'medio', 'enunciado': 'Complete: "Scientists _____ (discover) a new species in the Amazon last year."', 'alternativas': ['discover', 'discovers', 'discovered', 'discovering'], 'resposta_correta': 2, 'explicacao': 'Simple Past: discovered. Indicador temporal "last year" indica passado.', 'tags': ['simple_past', 'regular_verbs', 'time_markers'], 'metadata': {'tempo_estimado': 100, 'conceitos': ['simple_past']}},
  {'id': 'ing_7ano_007_there_is_are', 'subject': 'ingles', 'school_level': '7ano', 'difficulty': 'facil', 'enunciado': 'Choose the correct form: "_____ many different birds in the rainforest."', 'alternativas': ['There is', 'There are', 'It is', 'They are'], 'resposta_correta': 1, 'explicacao': 'There are + plural noun (many birds).', 'tags': ['there_is_are', 'plural', 'existence'], 'metadata': {'tempo_estimado': 80, 'conceitos': ['there_is_are']}},
  {'id': 'ing_7ano_008_present_continuous', 'subject': 'ingles', 'school_level': '7ano', 'difficulty': 'medio', 'enunciado': 'What is happening now? "The monkeys _____ in the trees right now."', 'alternativas': ['play', 'plays', 'are playing', 'is playing'], 'resposta_correta': 2, 'explicacao': 'Present Continuous (ação acontecendo agora): are + verb-ing.', 'tags': ['present_continuous', 'ing_form', 'current_action'], 'metadata': {'tempo_estimado': 110, 'conceitos': ['present_continuous']}},
  {'id': 'ing_7ano_009_prepositions_place', 'subject': 'ingles', 'school_level': '7ano', 'difficulty': 'medio', 'enunciado': 'Complete: "The jaguar is hiding _____ the trees."', 'alternativas': ['in', 'on', 'at', 'between'], 'resposta_correta': 3, 'explicacao': '"Between" indica posição entre múltiplos objetos (entre as árvores).', 'tags': ['prepositions', 'place', 'location'], 'metadata': {'tempo_estimado': 90, 'conceitos': ['prepositions_of_place']}},
  {'id': 'ing_7ano_010_comparatives', 'subject': 'ingles', 'school_level': '7ano', 'difficulty': 'medio', 'enunciado': 'Complete: "The Amazon River is _____ than the Nile River in length."', 'alternativas': ['long', 'longer', 'longest', 'more long'], 'resposta_correta': 1, 'explicacao': 'Comparative form: adjective + -er + than (longer than).', 'tags': ['comparatives', 'adjectives', 'comparison'], 'metadata': {'tempo_estimado': 100, 'conceitos': ['comparative_adjectives']}},
  {'id': 'ing_8ano_011_can_ability', 'subject': 'ingles', 'school_level': '8ano', 'difficulty': 'medio', 'enunciado': 'Complete: "Toucans _____ fly long distances through the forest."', 'alternativas': ['can', 'can to', 'cans', 'could to'], 'resposta_correta': 0, 'explicacao': 'Modal verb "can" + infinitive without "to" = ability.', 'tags': ['modal_verbs', 'can', 'ability'], 'metadata': {'tempo_estimado': 90, 'conceitos': ['modal_verbs']}},
  {'id': 'ing_8ano_012_must_obligation', 'subject': 'ingles', 'school_level': '8ano', 'difficulty': 'medio', 'enunciado': 'Complete: "We _____ protect the rainforest for future generations."', 'alternativas': ['must', 'musts', 'must to', 'have must'], 'resposta_correta': 0, 'explicacao': 'Modal verb "must" expresses obligation/necessity.', 'tags': ['modal_verbs', 'must', 'obligation'], 'metadata': {'tempo_estimado': 110, 'conceitos': ['modal_verbs']}},
  {'id': 'ing_8ano_013_question_formation', 'subject': 'ingles', 'school_level': '8ano', 'difficulty': 'medio', 'enunciado': 'Form the question: "How many trees _____ in the Amazon?"', 'alternativas': ['there is', 'is there', 'there are', 'are there'], 'resposta_correta': 3, 'explicacao': 'Question form: Are there + plural noun.', 'tags': ['questions', 'there_are', 'interrogative'], 'metadata': {'tempo_estimado': 100, 'conceitos': ['question_formation']}},
  {'id': 'ing_9ano_014_present_perfect', 'subject': 'ingles', 'school_level': '9ano', 'difficulty': 'dificil', 'enunciado': 'Complete: "Deforestation _____ (destroy) large areas of the Amazon in recent years."', 'alternativas': ['destroy', 'destroyed', 'has destroyed', 'have destroyed'], 'resposta_correta': 2, 'explicacao': 'Present Perfect: has/have + past participle. "Deforestation" (singular) + has destroyed.', 'tags': ['present_perfect', 'current_relevance', 'environmental'], 'metadata': {'tempo_estimado': 130, 'conceitos': ['present_perfect']}},
  {'id': 'ing_9ano_015_passive_voice_intro', 'subject': 'ingles', 'school_level': '9ano', 'difficulty': 'dificil', 'enunciado': 'Rewrite in passive voice: "People cut down many trees." → "Many trees _____ by people."', 'alternativas': ['cut down', 'are cut down', 'is cut down', 'were cut down'], 'resposta_correta': 1, 'explicacao': 'Passive Voice (Simple Present): are/is + past participle.', 'tags': ['passive_voice', 'voice_transformation'], 'metadata': {'tempo_estimado': 140, 'conceitos': ['passive_voice']}},
  {'id': 'ing_EM1_016_conditional_first', 'subject': 'ingles', 'school_level': 'EM1', 'difficulty': 'medio', 'enunciado': 'Complete with First Conditional: "If we _____ (protect) the forest, many species _____ (survive)."', 'alternativas': ['protect / will survive', 'will protect / survive', 'protected / would survive', 'protect / survive'], 'resposta_correta': 0, 'explicacao': 'First Conditional: If + Simple Present, will + infinitive.', 'tags': ['conditionals', 'first_conditional', 'real_possibility'], 'metadata': {'tempo_estimado': 140, 'conceitos': ['conditional_sentences']}},
  {'id': 'ing_EM1_017_passive_continuous', 'subject': 'ingles', 'school_level': 'EM1', 'difficulty': 'dificil', 'enunciado': 'Transform to Passive Voice: "Scientists are studying the Amazon ecosystem." → "The Amazon ecosystem _____ by scientists."', 'alternativas': ['is studying', 'is being studied', 'are being studied', 'has been studied'], 'resposta_correta': 1, 'explicacao': 'Passive Voice (Present Continuous): is/are + being + past participle.', 'tags': ['passive_voice', 'continuous_passive', 'transformation'], 'metadata': {'tempo_estimado': 150, 'conceitos': ['passive_continuous']}},
  {'id': 'ing_EM1_018_reported_speech', 'subject': 'ingles', 'school_level': 'EM1', 'difficulty': 'dificil', 'enunciado': 'Change to Reported Speech: The biologist said: "The rainforest is home to millions of species." → The biologist said that the rainforest _____ home to millions of species.', 'alternativas': ['is', 'was', 'has been', 'will be'], 'resposta_correta': 1, 'explicacao': 'Reported Speech: Present Simple → Past Simple (is → was).', 'tags': ['reported_speech', 'backshift', 'tense_change'], 'metadata': {'tempo_estimado': 160, 'conceitos': ['reported_speech']}},
  {'id': 'ing_EM1_019_relative_clauses', 'subject': 'ingles', 'school_level': 'EM1', 'difficulty': 'medio', 'enunciado': 'Complete with the correct relative pronoun: "The Amazon, _____ is the largest rainforest, produces 20% of world\'s oxygen."', 'alternativas': ['who', 'which', 'where', 'what'], 'resposta_correta': 1, 'explicacao': '"Which" is used for things/places in non-defining relative clauses.', 'tags': ['relative_clauses', 'which', 'non_defining'], 'metadata': {'tempo_estimado': 130, 'conceitos': ['relative_pronouns']}},
  {'id': 'ing_EM1_020_phrasal_verbs', 'subject': 'ingles', 'school_level': 'EM1', 'difficulty': 'medio', 'enunciado': 'Complete: "Conservationists are trying to _____ solutions to stop deforestation."', 'alternativas': ['come up with', 'come up', 'come with', 'come out'], 'resposta_correta': 0, 'explicacao': '"Come up with" = encontrar/criar (soluções, ideias).', 'tags': ['phrasal_verbs', 'come_up_with', 'idiomatic'], 'metadata': {'tempo_estimado': 120, 'conceitos': ['phrasal_verbs']}},
  {'id': 'ing_EM2_021_conditional_second', 'subject': 'ingles', 'school_level': 'EM2', 'difficulty': 'dificil', 'enunciado': 'Complete with Second Conditional: "If governments _____ (invest) more, we _____ (save) more forest areas."', 'alternativas': ['invest / will save', 'invested / would save', 'would invest / saved', 'invest / would save'], 'resposta_correta': 1, 'explicacao': 'Second Conditional (hypothetical): If + Past Simple, would + infinitive.', 'tags': ['conditionals', 'second_conditional', 'hypothetical'], 'metadata': {'tempo_estimado': 150, 'conceitos': ['conditional_sentences']}},
  {'id': 'ing_EM2_022_passive_perfect', 'subject': 'ingles', 'school_level': 'EM2', 'difficulty': 'dificil', 'enunciado': 'Transform to Passive Voice: "Researchers have discovered new species." → "New species _____ by researchers."', 'alternativas': ['have discovered', 'have been discovered', 'has been discovered', 'were discovered'], 'resposta_correta': 1, 'explicacao': 'Passive Voice (Present Perfect): have/has + been + past participle.', 'tags': ['passive_voice', 'perfect_passive', 'transformation'], 'metadata': {'tempo_estimado': 160, 'conceitos': ['passive_perfect']}},
  {'id': 'ing_EM2_023_linking_words', 'subject': 'ingles', 'school_level': 'EM2', 'difficulty': 'medio', 'enunciado': 'Choose the best linking word: "The forest is being destroyed; _____, many species are disappearing."', 'alternativas': ['however', 'therefore', 'although', 'because'], 'resposta_correta': 1, 'explicacao': '"Therefore" (portanto) shows consequence/result.', 'tags': ['linking_words', 'connectors', 'consequence'], 'metadata': {'tempo_estimado': 130, 'conceitos': ['discourse_markers']}},
  {'id': 'ing_EM2_024_modal_perfects', 'subject': 'ingles', 'school_level': 'EM2', 'difficulty': 'dificil', 'enunciado': 'Complete: "The government _____ more to protect the forest years ago." (criticism about past)', 'alternativas': ['should do', 'should have done', 'must have done', 'could do'], 'resposta_correta': 1, 'explicacao': '"Should have done" expresses criticism about something not done in the past.', 'tags': ['modal_perfects', 'should_have', 'past_criticism'], 'metadata': {'tempo_estimado': 150, 'conceitos': ['modal_perfects']}},
  {'id': 'ing_EM2_025_reading_inference', 'subject': 'ingles', 'school_level': 'EM2', 'difficulty': 'dificil', 'enunciado': 'Read: "Deforestation rates have slowed, but scientists warn this is not enough." What can we infer?', 'alternativas': ['The problem is completely solved', 'More action is still needed', 'Deforestation has stopped', 'Scientists are satisfied'], 'resposta_correta': 1, 'explicacao': '"Not enough" implies that more action is still necessary.', 'tags': ['reading', 'inference', 'critical_thinking'], 'metadata': {'tempo_estimado': 140, 'conceitos': ['reading_comprehension']}},
  {'id': 'ing_EM3_026_conditional_third', 'subject': 'ingles', 'school_level': 'EM3', 'difficulty': 'dificil', 'enunciado': 'Complete with Third Conditional: "If we _____ (act) sooner, we _____ (prevent) more damage."', 'alternativas': ['acted / would prevent', 'had acted / would have prevented', 'have acted / will prevent', 'would act / had prevented'], 'resposta_correta': 1, 'explicacao': 'Third Conditional (past unreal): If + Past Perfect, would have + past participle.', 'tags': ['conditionals', 'third_conditional', 'past_unreal'], 'metadata': {'tempo_estimado': 160, 'conceitos': ['conditional_sentences']}},
  {'id': 'ing_EM3_027_mixed_conditional', 'subject': 'ingles', 'school_level': 'EM3', 'difficulty': 'dificil', 'enunciado': 'Complete Mixed Conditional: "If humans _____ (not destroy) so much forest in the past, the climate _____ (be) better today."', 'alternativas': ['didn\'t destroy / would be', 'hadn\'t destroyed / would be', 'haven\'t destroyed / will be', 'don\'t destroy / would be'], 'resposta_correta': 1, 'explicacao': 'Mixed Conditional: If + Past Perfect (past), would + infinitive (present result).', 'tags': ['conditionals', 'mixed_conditional', 'advanced'], 'metadata': {'tempo_estimado': 180, 'conceitos': ['mixed_conditional']}},
  {'id': 'ing_EM3_028_inversion_emphasis', 'subject': 'ingles', 'school_level': 'EM3', 'difficulty': 'dificil', 'enunciado': 'Rewrite with inversion for emphasis: "We rarely see such biodiversity." → "_____ such biodiversity."', 'alternativas': ['Rarely we see', 'Rarely do we see', 'We rarely do see', 'Do we rarely see'], 'resposta_correta': 1, 'explicacao': 'After negative adverbs (rarely), use inversion: Rarely + auxiliary + subject + verb.', 'tags': ['inversion', 'emphasis', 'advanced_grammar'], 'metadata': {'tempo_estimado': 170, 'conceitos': ['inversion']}},
  {'id': 'ing_EM3_029_academic_vocabulary', 'subject': 'ingles', 'school_level': 'EM3', 'difficulty': 'medio', 'enunciado': 'Choose the best academic word: "Scientists _____ that deforestation affects global climate patterns."', 'alternativas': ['think', 'believe', 'contend', 'feel'], 'resposta_correta': 2, 'explicacao': '"Contend" (argumentar/afirmar) is more academic than "think" or "believe".', 'tags': ['academic_vocabulary', 'formal_language', 'enem'], 'metadata': {'tempo_estimado': 120, 'conceitos': ['academic_writing']}},
  {'id': 'ing_EM3_030_reading_critical', 'subject': 'ingles', 'school_level': 'EM3', 'difficulty': 'dificil', 'enunciado': 'Read: "While some argue economic growth justifies deforestation, environmentalists counter that long-term costs outweigh short-term gains." What\'s the author\'s stance?', 'alternativas': ['Supports deforestation', 'Opposes deforestation', 'Presents both views', 'No clear position'], 'resposta_correta': 2, 'explicacao': 'The text presents both perspectives (economic vs environmental) without taking sides.', 'tags': ['reading', 'argumentation', 'critical_analysis'], 'metadata': {'tempo_estimado': 160, 'conceitos': ['critical_reading']}},
];
