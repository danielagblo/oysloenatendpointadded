import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/chat_models.dart';

abstract class ChatRemoteDataSource {
  Future<String> getOrCreateChatRoomId({required String productId});

  Future<List<ChatRoomModel>> getChatRooms();

  Future<List<ChatMessageModel>> getMessages({
    required String chatRoomId,
  });

  Future<ChatMessageModel> sendMessage({
    required String chatRoomId,
    required String text,
  });

  Future<void> markChatRoomRead({required String chatRoomId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({required Dio client}) : _client = client;

  final Dio _client;

  @override
  Future<String> getOrCreateChatRoomId({required String productId}) async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(
        AppStrings.chatRoomIdURL,
        queryParameters: <String, dynamic>{'product': productId},
      );
      final dynamic data = response.data;
      if (data is Map<String, dynamic> && data['id'] != null) {
        return data['id'].toString();
      }
      throw const ServerException('Invalid chatroomid response');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      final Response<dynamic> response =
          await _client.get<dynamic>(AppStrings.chatRoomsURL);
      final dynamic data = response.data;
      if (data is List<dynamic>) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ChatRoomModel.fromJson)
            .toList();
      }
      throw const ServerException('Invalid chatrooms response');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages({
    required String chatRoomId,
  }) async {
    try {
      final String path = AppStrings.chatRoomMessagesURL(chatRoomId);
      final Response<dynamic> response = await _client.get<dynamic>(path);
      final dynamic data = response.data;
      if (data is List<dynamic>) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ChatMessageModel.fromJson)
            .toList();
      }
      throw const ServerException('Invalid messages response');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String chatRoomId,
    required String text,
  }) async {
    try {
      final String path = AppStrings.chatRoomSendMessageURL(chatRoomId);
      final Response<dynamic> response = await _client.post<dynamic>(
        path,
        data: <String, dynamic>{'text': text},
      );
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return ChatMessageModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      throw const ServerException('Invalid send message response');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<void> markChatRoomRead({required String chatRoomId}) async {
    try {
      final String path = AppStrings.chatRoomMarkReadURL(chatRoomId);
      await _client.post<dynamic>(path, data: <String, dynamic>{});
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}


