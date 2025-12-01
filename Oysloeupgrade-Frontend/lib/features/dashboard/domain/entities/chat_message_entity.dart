class ChatMessageEntity {
  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
    this.isMine = false,
    this.read = false,
  });

  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final bool isMine;
  final bool read;
}


