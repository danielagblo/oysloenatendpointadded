import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/referral_entity.dart';

class ReferralModel extends ReferralEntity {
  const ReferralModel({
    required super.referralCode,
    required super.points,
    required super.cashEquivalent,
    required super.currentLevel,
    required super.pointsToNextLevel,
    required super.totalPointsForNextLevel,
    required super.friendsReferred,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      referralCode: _parseString(json['referral_code']) ?? '',
      points: _parseInt(json['points']) ?? 0,
      cashEquivalent: _parseInt(json['cash_equivalent']) ?? 0,
      currentLevel: _parseString(json['current_level']) ?? 'Bronze',
      pointsToNextLevel: _parseInt(json['points_to_next_level']) ?? 0,
      totalPointsForNextLevel: _parseInt(json['total_points_for_next_level']) ?? 0,
      friendsReferred: _parseInt(json['friends_referred']) ?? 0,
    );
  }

  factory ReferralModel.fromEntity(ReferralEntity entity) {
    return ReferralModel(
      referralCode: entity.referralCode,
      points: entity.points,
      cashEquivalent: entity.cashEquivalent,
      currentLevel: entity.currentLevel,
      pointsToNextLevel: entity.pointsToNextLevel,
      totalPointsForNextLevel: entity.totalPointsForNextLevel,
      friendsReferred: entity.friendsReferred,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'referral_code': referralCode,
        'points': points,
        'cash_equivalent': cashEquivalent,
        'current_level': currentLevel,
        'points_to_next_level': pointsToNextLevel,
        'total_points_for_next_level': totalPointsForNextLevel,
        'friends_referred': friendsReferred,
      };

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final String result = value.toString().trim();
    return result.isEmpty ? null : result;
  }
}

class PointsTransactionModel extends PointsTransactionEntity {
  const PointsTransactionModel({
    required super.id,
    required super.date,
    required super.points,
    required super.amount,
    super.description,
  });

  factory PointsTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointsTransactionModel(
      id: _parseId(json['id']),
      date: DateUtilsExt.parseOrEpoch(json['date'] as String?) ?? DateTime.now(),
      points: _parseInt(json['points']) ?? 0,
      amount: _parseInt(json['amount']) ?? 0,
      description: _parseString(json['description']),
    );
  }

  factory PointsTransactionModel.fromEntity(PointsTransactionEntity entity) {
    return PointsTransactionModel(
      id: entity.id,
      date: entity.date,
      points: entity.points,
      amount: entity.amount,
      description: entity.description,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'date': date.toUtc().toIso8601String(),
        'points': points,
        'amount': amount,
        if (description != null) 'description': description,
      };

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final String result = value.toString().trim();
    return result.isEmpty ? null : result;
  }
}


