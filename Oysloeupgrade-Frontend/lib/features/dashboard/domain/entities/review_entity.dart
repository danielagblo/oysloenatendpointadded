import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userId,
    this.userEmail,
  });

  final int id;
  final String userName;
  final String userAvatar;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? userId;
  final String? userEmail;

  @override
  List<Object?> get props => <Object?>[
        id,
        userName,
        userAvatar,
        rating,
        comment,
        createdAt,
        userId,
        userEmail,
      ];
}
