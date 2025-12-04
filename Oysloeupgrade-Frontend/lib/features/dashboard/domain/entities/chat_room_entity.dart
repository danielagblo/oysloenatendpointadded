class ChatRoomEntity {
  const ChatRoomEntity({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isSupport = false,
    this.isClosed = false,
  });

  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isSupport;
  /// When true, the support case is closed and users should not be able
  /// to send new messages (read-only room).
  final bool isClosed;
}


