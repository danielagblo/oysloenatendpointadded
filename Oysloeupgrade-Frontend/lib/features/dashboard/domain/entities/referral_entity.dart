import 'package:equatable/equatable.dart';

class ReferralEntity extends Equatable {
  const ReferralEntity({
    required this.referralCode,
    required this.points,
    required this.cashEquivalent,
    required this.currentLevel,
    required this.pointsToNextLevel,
    required this.totalPointsForNextLevel,
    required this.friendsReferred,
  });

  final String referralCode;
  final int points;
  final int cashEquivalent;
  final String currentLevel;
  final int pointsToNextLevel;
  final int totalPointsForNextLevel;
  final int friendsReferred;

  double get progress {
    if (totalPointsForNextLevel == 0) return 0.0;
    final currentProgress = totalPointsForNextLevel - pointsToNextLevel;
    return (currentProgress / totalPointsForNextLevel).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        referralCode,
        points,
        cashEquivalent,
        currentLevel,
        pointsToNextLevel,
        totalPointsForNextLevel,
        friendsReferred,
      ];
}

class PointsTransactionEntity extends Equatable {
  const PointsTransactionEntity({
    required this.id,
    required this.date,
    required this.points,
    required this.amount,
    this.description,
  });

  final int id;
  final DateTime date;
  final int points;
  final int amount;
  final String? description;

  @override
  List<Object?> get props => [id, date, points, amount, description];
}


