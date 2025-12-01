import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

/// Utility class for common API operations and error handling
class ApiHelper {
  /// Extracts Map payload from Dio Response, throws ServerException if invalid
  static Map<String, dynamic> extractPayload(Response<dynamic> response) {
    if (response.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(response.data as Map<String, dynamic>);
    }
    if (response.data == null) {
      throw const ServerException('Empty response');
    }
    throw const ServerException('Invalid response structure');
  }

  /// Extracts human-readable error message from Dio response
  static String getHumanReadableMessage(DioException error) {
    final Response<dynamic>? response = error.response;
    if (response?.data is Map<String, dynamic>) {
      final Map<String, dynamic> map =
          Map<String, dynamic>.from(response!.data as Map<String, dynamic>);
      const List<String> keys = <String>[
        'message',
        'detail',
        'error',
        'error_message',
        'non_field_errors',
      ];
      for (final String key in keys) {
        if (!map.containsKey(key)) continue;
        final dynamic value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
        if (value is List && value.isNotEmpty) {
          for (final dynamic item in value) {
            if (item is String && item.trim().isNotEmpty) {
              return item.trim();
            }
          }
        }
      }
    }
    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }
    return 'Unable to complete request';
  }

  /// Gets user-friendly error message from DioException with fallback handling
  static String getDioExceptionMessage(DioException error) {
    if (error.response?.data is Map<String, dynamic>) {
      final data = error.response!.data as Map<String, dynamic>;
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection';
      case DioExceptionType.badResponse:
        return 'Something went wrong. Please try again';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network';
      default:
        return 'Something went wrong. Please try again';
    }
  }
}
