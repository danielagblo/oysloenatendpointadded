import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  CategoriesRemoteDataSourceImpl({
    required Dio client,
    this.endpoint = AppStrings.categoriesURL,
  }) : _client = client;

  final Dio _client;
  final String endpoint;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(endpoint);
      final dynamic data = response.data;

      if (data is List<dynamic>) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> item) =>
                  CategoryModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      if (data == null) {
        return const <CategoryModel>[];
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}
