import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';

abstract class DeletionReasonsRemoteDataSource {
  Future<List<String>> getDeletionReasons();
}

class DeletionReasonsRemoteDataSourceImpl
    implements DeletionReasonsRemoteDataSource {
  DeletionReasonsRemoteDataSourceImpl({
    required Dio client,
    this.endpoint = AppStrings.accountDeletionReasonsURL,
  }) : _client = client;

  final Dio _client;
  final String endpoint;

  @override
  Future<List<String>> getDeletionReasons() async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(endpoint);
      final dynamic data = response.data;

      if (data is List<dynamic>) {
        return data
            .whereType<String>()
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }

      // Handle case where API returns an object with a 'reasons' field
      if (data is Map<String, dynamic>) {
        final reasons = data['reasons'] ?? data['results'] ?? data['data'];
        if (reasons is List<dynamic>) {
          return reasons
              .whereType<String>()
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList();
        }
      }

      if (data == null) {
        return const <String>[];
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}

