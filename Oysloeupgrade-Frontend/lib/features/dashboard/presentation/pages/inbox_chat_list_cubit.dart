import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_room_entity.dart';
import '../../domain/usecases/chat_usecases.dart';
import '../../../../../core/usecase/usecase.dart';

class ChatListState {
  const ChatListState({
    this.rooms = const <ChatRoomEntity>[],
    this.loading = false,
    this.message,
  });

  final List<ChatRoomEntity> rooms;
  final bool loading;
  final String? message;

  int get totalUnread =>
      rooms.fold<int>(0, (int prev, ChatRoomEntity r) => prev + r.unreadCount);

  ChatListState copyWith({
    List<ChatRoomEntity>? rooms,
    bool? loading,
    String? message,
    bool resetMessage = false,
  }) {
    return ChatListState(
      rooms: rooms ?? this.rooms,
      loading: loading ?? this.loading,
      message: resetMessage ? null : message ?? this.message,
    );
  }
}

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit(this._getRooms) : super(const ChatListState());

  final GetChatRoomsUseCase _getRooms;

  Future<void> load() async {
    emit(state.copyWith(loading: true, resetMessage: true));
    final result = await _getRooms(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          loading: false,
          rooms: const <ChatRoomEntity>[],
          message: failure.message,
        ),
      ),
      (rooms) => emit(
        state.copyWith(
          loading: false,
          rooms: rooms,
          resetMessage: true,
        ),
      ),
    );
  }
}


