import 'package:equatable/equatable.dart';

class StaticPageEntity extends Equatable {
  const StaticPageEntity({
    required this.content,
    this.updatedAt,
  });

  final String content;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[content, updatedAt];
}


