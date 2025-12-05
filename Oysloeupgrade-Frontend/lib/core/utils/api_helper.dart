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
    
    // Handle server errors (500, 502, 503, etc.) with user-friendly messages
    if (response != null && response.statusCode != null) {
      if (response.statusCode! >= 500) {
        return 'Server error. Please try again in a moment.';
      }
      if (response.statusCode == 404) {
        return 'Resource not found. Please try again.';
      }
      if (response.statusCode == 403) {
        return 'You don\'t have permission to perform this action.';
      }
      if (response.statusCode == 401) {
        return 'Please log in to continue.';
      }
    }
    
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
    
    // Handle connection errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    }
    
    if (error.message != null && error.message!.isNotEmpty) {
      // Don't show raw technical error messages to users
      if (error.message!.contains('status code') ||
          error.message!.contains('RequestOptions') ||
          error.message!.contains('validateStatus')) {
        return 'Server error. Please try again in a moment.';
      }
      return error.message!;
    }
    return 'Unable to complete request. Please try again.';
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
