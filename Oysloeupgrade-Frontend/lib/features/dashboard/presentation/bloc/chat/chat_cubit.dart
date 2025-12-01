import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/chat_message_entity.dart';
import '../../../domain/usecases/chat_usecases.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._getMessages,
    this._sendMessage,
    this._markRead,
  ) : super(const ChatState());

  final GetChatMessagesUseCase _getMessages;
  final SendChatMessageUseCase _sendMessage;
  final MarkChatRoomReadUseCase _markRead;

  late String _chatRoomId;

  void setChatRoom(String chatRoomId) {
    _chatRoomId = chatRoomId;
  }

  Future<void> loadMessages() async {
    emit(
      state.copyWith(
        status: ChatStatus.loading,
        resetMessage: true,
      ),
    );

    final result = await _getMessages(ChatRoomParams(_chatRoomId));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ChatStatus.failure,
          messages: const <ChatMessageEntity>[],
          message: failure.message,
        ),
      ),
      (messages) => emit(
        state.copyWith(
          status: ChatStatus.success,
          messages: messages,
          resetMessage: true,
        ),
      ),
    );

    await _markRead(ChatRoomParams(_chatRoomId));
  }

  Future<void> send(String text) async {
    if (state.isSending || text.trim().isEmpty) return;

    emit(state.copyWith(isSending: true, resetMessage: true));

    final result = await _sendMessage(
      SendChatMessageParams(chatRoomId: _chatRoomId, text: text.trim()),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSending: false,
          message: failure.message,
        ),
      ),
      (sent) {
        final List<ChatMessageEntity> updated = <ChatMessageEntity>[
          ...state.messages,
          sent,
        ];
        emit(
          state.copyWith(
            isSending: false,
            messages: updated,
            resetMessage: true,
          ),
        );
      },
    );
  }
}


