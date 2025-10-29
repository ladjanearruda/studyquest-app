// verificar_questoes_problematicas.dart
// 🔍 VERIFICAR QUESTÕES SEM ALTERNATIVAS NO FIREBASE
// Coloque em: lib/scripts/verificar_questoes_problematicas.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ⚠️ AJUSTE O IMPORT ABAIXO PARA O SEU firebase_options.dart
// Se estiver em lib/scripts/, use: '../firebase_options.dart'
// Se estiver em outro lugar, ajuste o caminho
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔍 VERIFICANDO QUESTÕES NO FIREBASE');
  print('====================================\n');

  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase conectado\n');

    final firestore = FirebaseFirestore.instance;

    print('📥 Buscando todas questões...');
    final snapshot = await firestore.collection('questions').get();

    print('✅ ${snapshot.docs.length} questões carregadas\n');
    print('🔍 Analisando questões...\n');

    int questoesComProblema = 0;
    List<Map<String, dynamic>> problemasEncontrados = [];

    // Analisar cada questão
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final id = doc.id;

      bool temProblema = false;
      String motivoProblema = '';
      dynamic alternativas;

      // Verificar alternativas
      if (!data.containsKey('alternativas')) {
        temProblema = true;
        motivoProblema = 'Campo "alternativas" não existe';
        alternativas = null;
      } else {
        alternativas = data['alternativas'];

        if (alternativas == null) {
          temProblema = true;
          motivoProblema = 'Campo "alternativas" é null';
        } else if (alternativas is! List) {
          temProblema = true;
          motivoProblema =
              'Campo "alternativas" não é uma lista (tipo: ${alternativas.runtimeType})';
        } else if (alternativas.isEmpty) {
          temProblema = true;
          motivoProblema = 'Lista "alternativas" está vazia []';
        } else if (alternativas.length < 4) {
          temProblema = true;
          motivoProblema =
              'Lista "alternativas" tem apenas ${alternativas.length} itens (precisa de 4)';
        }
      }

      if (temProblema) {
        questoesComProblema++;

        // Extrair dados da questão
        final subject = data['subject'] ?? 'N/A';
        final schoolLevel = data['school_level'] ?? 'N/A';
        final enunciado = data['enunciado'] ?? 'N/A';
        final enunciadoPreview = enunciado.length > 60
            ? '${enunciado.substring(0, 60)}...'
            : enunciado;

        problemasEncontrados.add({
          'id': id,
          'subject': subject,
          'school_level': schoolLevel,
          'enunciado': enunciadoPreview,
          'motivo': motivoProblema,
          'alternativas_valor': alternativas,
        });
      }
    }

    // ════════════════════════════════════════════════════════════
    // RELATÓRIO FINAL
    // ════════════════════════════════════════════════════════════

    print('\n═══════════════════════════════════════════════════════════');
    print('📊 RELATÓRIO DE VERIFICAÇÃO');
    print('═══════════════════════════════════════════════════════════\n');

    print('✅ Total de questões no Firebase: ${snapshot.docs.length}');
    print(
        '✅ Questões válidas (4+ alternativas): ${snapshot.docs.length - questoesComProblema}');
    print('❌ Questões com problema: $questoesComProblema\n');

    if (questoesComProblema > 0) {
      print('═══════════════════════════════════════════════════════════');
      print('🚨 QUESTÕES PROBLEMÁTICAS ENCONTRADAS');
      print('═══════════════════════════════════════════════════════════\n');

      for (var i = 0; i < problemasEncontrados.length; i++) {
        final problema = problemasEncontrados[i];

        print('─────────────────────────────────────────────────────────');
        print('Questão ${i + 1}/$questoesComProblema:');
        print('');
        print('   ID: ${problema['id']}');
        print('   Matéria: ${problema['subject']}');
        print('   Nível: ${problema['school_level']}');
        print('   Enunciado: ${problema['enunciado']}');
        print('');
        print('   ⚠️  PROBLEMA: ${problema['motivo']}');
        print('   Valor atual: ${problema['alternativas_valor']}');
        print('');
      }

      print('═══════════════════════════════════════════════════════════');
      print('📋 LISTA DE IDs (para fácil cópia)');
      print('═══════════════════════════════════════════════════════════\n');

      for (var problema in problemasEncontrados) {
        print(problema['id']);
      }

      print('\n═══════════════════════════════════════════════════════════');
      print('💡 PRÓXIMOS PASSOS');
      print('═══════════════════════════════════════════════════════════\n');
      print('1. Copie os IDs listados acima');
      print('2. Acesse Firebase Console:');
      print('   https://console.firebase.google.com/');
      print('3. Navegue até: Firestore Database > questions');
      print('4. Para cada ID problemático, escolha:');
      print('   a) Corrigir: Adicionar 4 alternativas válidas');
      print('   b) Deletar: Se não souber o conteúdo correto');
      print('5. Execute este script novamente para confirmar\n');
    } else {
      print('═══════════════════════════════════════════════════════════');
      print('🎉 PERFEITO! TODAS AS QUESTÕES ESTÃO OK!');
      print('═══════════════════════════════════════════════════════════\n');
      print('✅ Todas as ${snapshot.docs.length} questões têm 4+ alternativas');
      print('✅ Sistema pronto para funcionar corretamente\n');
    }
  } catch (e, stackTrace) {
    print('\n❌ ERRO AO EXECUTAR SCRIPT:');
    print('═══════════════════════════════════════════════════════════\n');
    print('Erro: $e\n');
    print('Stack trace:');
    print(stackTrace);
    print('\n💡 DICAS DE SOLUÇÃO:');
    print('───────────────────────────────────────────────────────────');
    print('1. Verifique se firebase_options.dart existe');
    print('2. Verifique o import no topo deste arquivo');
    print('3. Execute: flutter pub get');
    print('4. Tente novamente\n');
  }
}
