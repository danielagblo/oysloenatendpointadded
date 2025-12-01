import '../../../domain/entities/chat_message_entity.dart';

enum ChatStatus {
  initial,
  loading,
  success,
  failure,
}

class ChatState {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const <ChatMessageEntity>[],
    this.isSending = false,
    this.message,
  });

  final ChatStatus status;
  final List<ChatMessageEntity> messages;
  final bool isSending;
  final String? message;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessageEntity>? messages,
    bool? isSending,
    String? message,
    bool resetMessage = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      message: resetMessage ? null : message ?? this.message,
    );
  }
}


