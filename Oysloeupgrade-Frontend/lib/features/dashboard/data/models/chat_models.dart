import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    required super.otherUserId,
    required super.otherUserName,
    super.otherUserAvatar,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCount,
    super.isSupport,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'].toString(),
      otherUserId: json['other_user_id'].toString(),
      otherUserName: (json['other_user_name'] ?? '').toString(),
      otherUserAvatar: json['other_user_avatar']?.toString(),
      lastMessage: json['last_message']?.toString(),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString())
          : null,
      unreadCount: json['unread_count'] is int
          ? json['unread_count'] as int
          : int.tryParse('${json['unread_count']}') ?? 0,
      isSupport: json['is_support'] == true ||
          (json['kind']?.toString().toLowerCase() == 'support'),
    );
  }
}

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.authorId,
    required super.authorName,
    super.authorAvatar,
    required super.createdAt,
    super.isMine,
    super.read,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'].toString(),
      text: (json['text'] ?? '').toString(),
      authorId: json['author_id'].toString(),
      authorName: (json['author_name'] ?? '').toString(),
      authorAvatar: json['author_avatar']?.toString(),
      createdAt: DateTime.tryParse(json['created_at'].toString()) ??
          DateTime.now(),
      isMine: json['is_mine'] == true,
      read: json['read'] == true,
    );
  }
}


