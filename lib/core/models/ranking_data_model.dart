// lib/core/models/ranking_data_model.dart
// Model para Dados Completos do Ranking
// Sprint 7 - Observatório Educacional MVP

import 'package:studyquest_app/core/models/user_score_model.dart';

class RankingData {
  final UserScore userPosition;
  final List<UserScore> top10Geral;
  final List<UserScore> top10Serie;
  final List<UserScore> top10Estado;
  final int totalUsers;
  final int pointsToNextPosition;

  RankingData({
    required this.userPosition,
    required this.top10Geral,
    required this.top10Serie,
    required this.top10Estado,
    required this.totalUsers,
    required this.pointsToNextPosition,
  });

  /// Cria RankingData vazio (para loading)
  factory RankingData.empty() {
    return RankingData(
      userPosition: UserScore.empty(),
      top10Geral: [],
      top10Serie: [],
      top10Estado: [],
      totalUsers: 0,
      pointsToNextPosition: 0,
    );
  }

  /// Verifica se está vazio (loading state)
  bool get isEmpty =>
      userPosition.userId.isEmpty &&
      top10Geral.isEmpty &&
      top10Serie.isEmpty &&
      top10Estado.isEmpty;

  /// Verifica se tem dados carregados
  bool get hasData => !isEmpty;

  /// Cria cópia com mudanças
  RankingData copyWith({
    UserScore? userPosition,
    List<UserScore>? top10Geral,
    List<UserScore>? top10Serie,
    List<UserScore>? top10Estado,
    int? totalUsers,
    int? pointsToNextPosition,
  }) {
    return RankingData(
      userPosition: userPosition ?? this.userPosition,
      top10Geral: top10Geral ?? this.top10Geral,
      top10Serie: top10Serie ?? this.top10Serie,
      top10Estado: top10Estado ?? this.top10Estado,
      totalUsers: totalUsers ?? this.totalUsers,
      pointsToNextPosition: pointsToNextPosition ?? this.pointsToNextPosition,
    );
  }

  @override
  String toString() {
    return 'RankingData(userPos: ${userPosition.position}, top10: ${top10Geral.length}, serie: ${top10Serie.length}, estado: ${top10Estado.length})';
  }
}
