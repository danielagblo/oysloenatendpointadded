class ChatRoomEntity {
  const ChatRoomEntity({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
}


