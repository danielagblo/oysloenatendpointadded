import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../../domain/entities/static_page_entity.dart';

/// Fetches static page contents such as privacy policy and terms.
abstract class StaticPagesRemoteDataSource {
  Future<StaticPageEntity> fetchPrivacyPolicy();
  Future<StaticPageEntity> fetchTermsConditions();
}

class StaticPagesRemoteDataSourceImpl implements StaticPagesRemoteDataSource {
  StaticPagesRemoteDataSourceImpl({
    required Dio client,
  }) : _client = client;

  final Dio _client;

  @override
  Future<StaticPageEntity> fetchPrivacyPolicy() async {
    return _fetchContent(AppStrings.privacyPoliciesLatestURL);
  }

  @override
  Future<StaticPageEntity> fetchTermsConditions() async {
    return _fetchContent(AppStrings.termsConditionsLatestURL);
  }

  Future<StaticPageEntity> _fetchContent(String url) async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(url);
      final dynamic data = response.data;

      if (data is Map<String, dynamic>) {
        // Prefer 'content' key if present, otherwise flatten to string.
        final dynamic content = data['content'] ?? data['body'] ?? data['text'];
        final DateTime? updatedAt = _parseDate(
          data['updated_at'] ?? data['created_at'] ?? data['date'],
        );
        if (content is String && content.trim().isNotEmpty) {
          return StaticPageEntity(content: content, updatedAt: updatedAt);
        }
        // If map contains only string values, join them.
        final String joined = data.values
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .join('\n\n');
        if (joined.isNotEmpty) {
          return StaticPageEntity(content: joined, updatedAt: updatedAt);
        }
      } else if (data is String && data.trim().isNotEmpty) {
        return StaticPageEntity(content: data, updatedAt: null);
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      return parsed;
    }
    return null;
  }
}

