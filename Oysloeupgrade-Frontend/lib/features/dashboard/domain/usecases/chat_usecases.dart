import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/chat_room_entity.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetOrCreateChatRoomIdParams {
  const GetOrCreateChatRoomIdParams({
    required this.productId,
    this.userId,
  });

  final int productId;
  final String? userId;
}

class GetOrCreateChatRoomIdUseCase
    implements UseCase<String, GetOrCreateChatRoomIdParams> {
  GetOrCreateChatRoomIdUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, String>> call(GetOrCreateChatRoomIdParams params) {
    return _repository.getOrCreateChatRoomId(
      productId: params.productId,
      userId: params.userId,
    );
  }
}

class GetChatRoomsParams {
  const GetChatRoomsParams({this.isSupport});

  final bool? isSupport;
}

class GetChatRoomsUseCase
    implements UseCase<List<ChatRoomEntity>, GetChatRoomsParams> {
  GetChatRoomsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<ChatRoomEntity>>> call(
    GetChatRoomsParams params,
  ) {
    return _repository.getChatRooms(isSupport: params.isSupport);
  }
}

class ChatRoomParams {
  const ChatRoomParams(this.chatRoomId);

  final String chatRoomId;
}

class GetChatMessagesUseCase
    implements UseCase<List<ChatMessageEntity>, ChatRoomParams> {
  GetChatMessagesUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> call(
    ChatRoomParams params,
  ) {
    return _repository.getChatMessages(chatRoomId: params.chatRoomId);
  }
}

class SendChatMessageParams {
  const SendChatMessageParams({required this.chatRoomId, required this.text});

  final String chatRoomId;
  final String text;
}

class SendChatMessageUseCase
    implements UseCase<ChatMessageEntity, SendChatMessageParams> {
  SendChatMessageUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ChatMessageEntity>> call(
    SendChatMessageParams params,
  ) {
    return _repository.sendChatMessage(
      chatRoomId: params.chatRoomId,
      text: params.text,
    );
  }
}

class MarkChatRoomReadUseCase
    implements UseCase<void, ChatRoomParams> {
  MarkChatRoomReadUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, void>> call(ChatRoomParams params) {
    return _repository.markChatRoomRead(chatRoomId: params.chatRoomId);
  }
}


