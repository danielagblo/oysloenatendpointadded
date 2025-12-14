import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/subcategory_model.dart';

abstract class SubcategoriesRemoteDataSource {
  Future<List<SubcategoryModel>> getSubcategories({int? categoryId});
}

class SubcategoriesRemoteDataSourceImpl
    implements SubcategoriesRemoteDataSource {
  SubcategoriesRemoteDataSourceImpl({
    required Dio client,
    this.endpoint = AppStrings.subcategoriesURL,
  }) : _client = client;

  final Dio _client;
  final String endpoint;

  @override
  Future<List<SubcategoryModel>> getSubcategories({int? categoryId}) async {
    try {
      final queryParams = categoryId != null ? {'category': categoryId} : null;
      print('Fetching subcategories with categoryId=$categoryId, queryParams=$queryParams');
      final Response<dynamic> response =
          await _client.get<dynamic>(endpoint, queryParameters: queryParams);
      final dynamic data = response.data;
      print('Subcategories API response: ${data is List ? data.length : 'not a list'} items');

      if (data is List<dynamic>) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> item) =>
                  SubcategoryModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      if (data == null) {
        return const <SubcategoryModel>[];
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}
