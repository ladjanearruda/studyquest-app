// lib/features/observatorio/services/ranking_service.dart
// Service para Comunicação com Firebase (Rankings)
// Sprint 7 - Observatório Educacional MVP

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studyquest_app/core/models/user_score_model.dart';
import 'package:studyquest_app/core/models/ranking_data_model.dart';
import 'package:studyquest_app/features/observatorio/services/scoring_service.dart';

class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Atualiza score do usuário no Firebase
  /// Salva em 3 lugares: geral, por série, por estado
  Future<void> updateUserScore(UserScore userScore) async {
    try {
      print('📊 Atualizando score usuário: ${userScore.userId}');

      // 1. Atualizar ranking geral
      await _firestore
          .collection('rankings')
          .doc('geral')
          .collection('users')
          .doc(userScore.userId)
          .set(userScore.toJson(), SetOptions(merge: true));

      print('   ✅ Ranking geral atualizado');

      // 2. Atualizar ranking por série
      await _firestore
          .collection('rankings')
          .doc('por_serie')
          .collection(userScore.schoolLevel)
          .doc(userScore.userId)
          .set(userScore.toJson(), SetOptions(merge: true));

      print('   ✅ Ranking série ${userScore.schoolLevel} atualizado');

      // 3. Atualizar ranking por estado
      await _firestore
          .collection('rankings')
          .doc('por_estado')
          .collection(userScore.state)
          .doc(userScore.userId)
          .set(userScore.toJson(), SetOptions(merge: true));

      print('   ✅ Ranking estado ${userScore.state} atualizado');
      print('✅ Score atualizado com sucesso!');
    } catch (e) {
      print('❌ Erro ao atualizar score: $e');
      rethrow;
    }
  }

  /// Busca posição do usuário no ranking geral
  Future<UserScore> getUserRanking(String userId) async {
    try {
      print('📊 Buscando posição do usuário: $userId');

      final doc = await _firestore
          .collection('rankings')
          .doc('geral')
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final userScore = UserScore.fromJson(doc.data()!);
        print('✅ Posição encontrada: ${userScore.position}º lugar');
        return userScore;
      } else {
        print('⚠️ Usuário não encontrado no ranking');
        throw Exception('Usuário não encontrado no ranking');
      }
    } catch (e) {
      print('❌ Erro ao buscar posição usuário: $e');
      rethrow;
    }
  }

  /// Busca Top N do ranking geral
  Future<List<UserScore>> getTopRanking({int limit = 10}) async {
    try {
      print('📊 Buscando Top $limit ranking geral...');

      final snapshot = await _firestore
          .collection('rankings')
          .doc('geral')
          .collection('users')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final rankings =
          snapshot.docs.map((doc) => UserScore.fromJson(doc.data())).toList();

      print('✅ Top $limit carregado: ${rankings.length} usuários');

      // Atualizar posições baseado na ordem
      for (int i = 0; i < rankings.length; i++) {
        rankings[i] = rankings[i].copyWith(position: i + 1);
      }

      return rankings;
    } catch (e) {
      print('❌ Erro ao buscar top ranking: $e');
      return [];
    }
  }

  /// Busca ranking por série escolar
  Future<List<UserScore>> getRankingBySerie(
    String schoolLevel, {
    int limit = 10,
  }) async {
    try {
      print('📊 Buscando Top $limit da série $schoolLevel...');

      final snapshot = await _firestore
          .collection('rankings')
          .doc('por_serie')
          .collection(schoolLevel)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final rankings =
          snapshot.docs.map((doc) => UserScore.fromJson(doc.data())).toList();

      print('✅ Top $limit série carregado: ${rankings.length} usuários');

      // Atualizar posições baseado na ordem
      for (int i = 0; i < rankings.length; i++) {
        rankings[i] = rankings[i].copyWith(position: i + 1);
      }

      return rankings;
    } catch (e) {
      print('❌ Erro ao buscar ranking série: $e');
      return [];
    }
  }

  /// Busca ranking por estado
  Future<List<UserScore>> getRankingByEstado(
    String state, {
    int limit = 10,
  }) async {
    try {
      print('📊 Buscando Top $limit do estado $state...');

      final snapshot = await _firestore
          .collection('rankings')
          .doc('por_estado')
          .collection(state)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final rankings =
          snapshot.docs.map((doc) => UserScore.fromJson(doc.data())).toList();

      print('✅ Top $limit estado carregado: ${rankings.length} usuários');

      // Atualizar posições baseado na ordem
      for (int i = 0; i < rankings.length; i++) {
        rankings[i] = rankings[i].copyWith(position: i + 1);
      }

      return rankings;
    } catch (e) {
      print('❌ Erro ao buscar ranking estado: $e');
      return [];
    }
  }

  /// Busca todos os dados do ranking de uma vez (MÉTODO PRINCIPAL)
  /// Usa: getUserRanking + getTopRanking + getRankingBySerie + getRankingByEstado
  Future<RankingData> getRankingData(
    String userId,
    UserScore userScore,
  ) async {
    try {
      print('📊 Carregando dados completos ranking para $userId...');

      // Buscar Top 10 geral
      final top10Geral = await getTopRanking(limit: 10);
      print('   ✅ Top 10 geral carregado');

      // Buscar Top 10 série
      final top10Serie = await getRankingBySerie(
        userScore.schoolLevel,
        limit: 10,
      );
      print('   ✅ Top 10 série carregado');

      // Buscar Top 10 estado
      final top10Estado = await getRankingByEstado(
        userScore.state,
        limit: 10,
      );
      print('   ✅ Top 10 estado carregado');

      // Calcular total de usuários (aproximado)
      // TODO: Implementar contagem real quando tiver muitos usuários
      final totalUsers = top10Geral.length * 10; // Estimativa temporária

      // Calcular pontos até próxima posição
      int pointsToNext = 0;
      if (userScore.position > 1 && top10Geral.isNotEmpty) {
        // Buscar usuário na posição acima
        final nextUser = top10Geral.firstWhere(
          (u) => u.position == userScore.position - 1,
          orElse: () => top10Geral.first,
        );

        pointsToNext = ScoringService.pointsToNextPosition(
          currentScore: userScore.score,
          nextPositionScore: nextUser.score,
        );
      }

      print('✅ Dados ranking carregados completos!');
      print('   └─ Posição usuário: ${userScore.position}º');
      print('   └─ Top 10 geral: ${top10Geral.length} usuários');
      print('   └─ Top 10 série: ${top10Serie.length} usuários');
      print('   └─ Top 10 estado: ${top10Estado.length} usuários');
      print('   └─ Pontos faltando: $pointsToNext');

      return RankingData(
        userPosition: userScore,
        top10Geral: top10Geral,
        top10Serie: top10Serie,
        top10Estado: top10Estado,
        totalUsers: totalUsers,
        pointsToNextPosition: pointsToNext,
      );
    } catch (e) {
      print('❌ Erro ao carregar dados ranking: $e');
      return RankingData.empty();
    }
  }

  /// Conta total de usuários em um ranking específico
  /// (Método auxiliar - usa para cálculos futuros)
  Future<int> countUsersInRanking(String rankingType) async {
    try {
      final snapshot = await _firestore
          .collection('rankings')
          .doc(rankingType)
          .collection('users')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Erro ao contar usuários: $e');
      return 0;
    }
  }
}
