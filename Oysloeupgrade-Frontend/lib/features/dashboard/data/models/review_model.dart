import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userName,
    required super.userAvatar,
    required super.rating,
    required super.comment,
    required super.createdAt,
    super.userId,
    super.userEmail,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;

    final String userName = _resolveString(user?['name']) ??
        _resolveString(user?['email']) ??
        'Oysloe user';

    final int rawRating = json['rating'] is int
        ? json['rating'] as int
        : int.tryParse(json['rating']?.toString() ?? '') ?? 0;
    final int rating = rawRating.clamp(0, 5);

    return ReviewModel(
      id: json['id'] as int? ?? 0,
      userName: userName,
      userAvatar: _resolveString(user?['avatar']) ?? '',
      rating: rating,
      comment: _resolveString(json['comment']) ?? '',
      createdAt: DateUtilsExt.parseOrEpoch(json['created_at'] as String?),
      userId: _resolveString(user?['id']),
      userEmail: _resolveString(user?['email']),
    );
  }

  static String? _resolveString(dynamic value) {
    if (value == null) return null;
    final String result = value.toString().trim();
    return result.isEmpty ? null : result;
  }
}
