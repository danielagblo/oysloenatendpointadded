import 'package:equatable/equatable.dart';

class AlertEntity extends Equatable {
  const AlertEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String kind;
  final bool isRead;
  final DateTime createdAt;

  AlertEntity copyWith({
    bool? isRead,
  }) {
    return AlertEntity(
      id: id,
      title: title,
      body: body,
      kind: kind,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        body,
        kind,
        isRead,
        createdAt,
      ];
}
