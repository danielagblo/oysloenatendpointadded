import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/feature_model.dart';

abstract class FeaturesRemoteDataSource {
  Future<List<FeatureModel>> getFeatures({int? subcategoryId});
  Future<List<String>> getFeatureValues(int featureId);
}

class FeaturesRemoteDataSourceImpl implements FeaturesRemoteDataSource {
  FeaturesRemoteDataSourceImpl({
    required Dio client,
    this.endpoint = AppStrings.featuresURL,
    this.valuesEndpoint = AppStrings.featureValuesURL,
  }) : _client = client;

  final Dio _client;
  final String endpoint;
  final String valuesEndpoint;

  @override
  Future<List<FeatureModel>> getFeatures({int? subcategoryId}) async {
    try {
      final queryParams =
          subcategoryId != null ? {'subcategory': subcategoryId} : null;
      final Response<dynamic> response =
          await _client.get<dynamic>(endpoint, queryParameters: queryParams);
      final dynamic data = response.data;

      if (data is List<dynamic>) {
        final features = data
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> item) =>
                  FeatureModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();

        return features;
      }

      if (data == null) {
        return const <FeatureModel>[];
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<List<String>> getFeatureValues(int featureId) async {
    try {
      print('Fetching values from: $valuesEndpoint?feature=$featureId');
      final Response<dynamic> response = await _client.get<dynamic>(
        valuesEndpoint,
        queryParameters: {'feature': featureId},
      );
      print('Response status: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');
      final dynamic data = response.data;

      if (data is List<dynamic>) {
        print('Data is a list with ${data.length} items');
        final values = data
            .whereType<Map<String, dynamic>>()
            .map((item) {
              print('Processing item: $item');
              // Extract the 'value' field from each object
              final value = item['value'];
              if (value == null) return '';
              return value.toString().trim();
            })
            .where((value) => value.isNotEmpty)
            .toList();

        print(
            'Fetched ${values.length} values for feature $featureId: $values');
        return values;
      }

      print('Data is not a list, returning empty array');
      return const <String>[];
    } on DioException catch (error) {
      print('Feature values DioException: ${error.message}');
      print('Error response: ${error.response?.data}');
      print('Error status: ${error.response?.statusCode}');
      return const <String>[];
    } catch (error) {
      print('Error fetching feature values: $error');
      print('Error stacktrace: ${StackTrace.current}');
      return const <String>[];
    }
  }
}
