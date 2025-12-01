import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/account_delete_request_model.dart';

abstract class AccountDeleteRequestsRemoteDataSource {
  /// List all account delete requests.
  Future<List<AccountDeleteRequestModel>> getRequests();

  /// Create a new account delete request for the currently authenticated user.
  Future<AccountDeleteRequestModel> createRequest({String? reason});

  /// Get a specific request by id.
  Future<AccountDeleteRequestModel> getRequest(int id);

  /// Update an existing request (e.g. change reason or status).
  Future<AccountDeleteRequestModel> updateRequest(
    int id, {
    String? reason,
    String? status,
  });

  /// Partially update a request (PATCH).
  Future<AccountDeleteRequestModel> patchRequest(
    int id, {
    Map<String, dynamic>? data,
  });

  /// Delete a request.
  Future<void> deleteRequest(int id);

  /// Approve a request (admin).
  Future<AccountDeleteRequestModel> approveRequest(int id);

  /// Reject a request (admin).
  Future<AccountDeleteRequestModel> rejectRequest(int id);
}

class AccountDeleteRequestsRemoteDataSourceImpl
    implements AccountDeleteRequestsRemoteDataSource {
  AccountDeleteRequestsRemoteDataSourceImpl({
    required Dio client,
    this.endpoint = AppStrings.accountDeleteRequestsURL,
  }) : _client = client;

  final Dio _client;
  final String endpoint;

  @override
  Future<List<AccountDeleteRequestModel>> getRequests() async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(endpoint);
      final dynamic data = response.data;

      if (data is List<dynamic>) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> raw) =>
                  AccountDeleteRequestModel.fromJson(raw),
            )
            .toList();
      }

      if (data == null) {
        return <AccountDeleteRequestModel>[];
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<AccountDeleteRequestModel> createRequest({String? reason}) async {
    try {
      final Response<dynamic> response =
          await _client.post<dynamic>(endpoint, data: <String, dynamic>{
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      });

      if (response.data is Map<String, dynamic>) {
        return AccountDeleteRequestModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<AccountDeleteRequestModel> getRequest(int id) async {
    final String path = AppStrings.accountDeleteRequestDetailURL('$id');
    try {
      final Response<dynamic> response = await _client.get<dynamic>(path);
      if (response.data is Map<String, dynamic>) {
        return AccountDeleteRequestModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<AccountDeleteRequestModel> updateRequest(
    int id, {
    String? reason,
    String? status,
  }) async {
    final String path = AppStrings.accountDeleteRequestDetailURL('$id');
    final Map<String, dynamic> payload = <String, dynamic>{};
    if (reason != null && reason.trim().isNotEmpty) {
      payload['reason'] = reason.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      payload['status'] = status.trim();
    }

    try {
      final Response<dynamic> response = await _client.put<dynamic>(
        path,
        data: payload,
      );
      if (response.data is Map<String, dynamic>) {
        return AccountDeleteRequestModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<AccountDeleteRequestModel> patchRequest(
    int id, {
    Map<String, dynamic>? data,
  }) async {
    final String path = AppStrings.accountDeleteRequestDetailURL('$id');
    try {
      final Response<dynamic> response = await _client.patch<dynamic>(
        path,
        data: data ?? <String, dynamic>{},
      );
      if (response.data is Map<String, dynamic>) {
        return AccountDeleteRequestModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<void> deleteRequest(int id) async {
    final String path = AppStrings.accountDeleteRequestDetailURL('$id');
    try {
      await _client.delete<dynamic>(path);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<AccountDeleteRequestModel> approveRequest(int id) async {
    final String path = AppStrings.accountDeleteRequestApproveURL('$id');
    try {
      final Response<dynamic> response =
          await _client.post<dynamic>(path, data: <String, dynamic>{});
      if (response.data is Map<String, dynamic>) {
        return AccountDeleteRequestModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<AccountDeleteRequestModel> rejectRequest(int id) async {
    final String path = AppStrings.accountDeleteRequestRejectURL('$id');
    try {
      final Response<dynamic> response =
          await _client.post<dynamic>(path, data: <String, dynamic>{});
      if (response.data is Map<String, dynamic>) {
        return AccountDeleteRequestModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}


