import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? search,
    String? ordering,
  });

  Future<ProductModel> getProductDetail(int id);

  Future<List<ProductModel>> getRelatedProducts({
    required int productId,
  });

  Future<ProductModel> markProductAsTaken({
    required int productId,
  });

  Future<ProductModel> setProductStatus({
    required int productId,
    required String status,
  });

  Future<void> deleteProduct({
    required int productId,
  });

  Future<void> reportProduct({
    required int productId,
    required String reason,
  });

  Future<List<ReviewModel>> getProductReviews({
    required int productId,
  });

  Future<ReviewModel> createReview({
    required int productId,
    required int rating,
    String? comment,
  });

  Future<ReviewModel> updateReview({
    required int reviewId,
    required int rating,
    String? comment,
  });

  Future<ProductModel> createProduct({
    required String name,
    required String description,
    required String price,
    required String type,
    required int category,
    String? duration,
    List<String>? images,
  });
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImpl({
    required Dio client,
    this.endpoint = AppStrings.productsURL,
  }) : _client = client;

  final Dio _client;
  final String endpoint;

  @override
  Future<List<ProductModel>> getProducts({
    String? search,
    String? ordering,
  }) async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(
        endpoint,
        queryParameters: _buildQuery(
          search: search,
          ordering: ordering,
        ),
      );
      return _parseProductList(response.data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<ProductModel> getProductDetail(int id) async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(
        AppStrings.productDetailURL(id.toString()),
      );
      return _parseProduct(response.data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<List<ProductModel>> getRelatedProducts({
    required int productId,
  }) async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(
        AppStrings.relatedProductsURL,
        queryParameters: <String, dynamic>{'product': productId},
      );
      return _parseProductList(response.data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<ProductModel> markProductAsTaken({
    required int productId,
  }) async {
    try {
      final Response<dynamic> response = await _client.post<dynamic>(
        AppStrings.markProductAsTakenURL(productId.toString()),
        data: const <String, dynamic>{},
      );
      return _parseProduct(response.data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<ProductModel> setProductStatus({
    required int productId,
    required String status,
  }) async {
    try {
      final Response<dynamic> response = await _client.put<dynamic>(
        AppStrings.setProductStatusURL(productId.toString()),
        data: <String, dynamic>{'status': status},
      );
      return _parseProduct(response.data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<void> deleteProduct({required int productId}) async {
    try {
      await _client.delete<dynamic>(
        AppStrings.productDetailURL(productId.toString()),
      );
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<void> reportProduct({
    required int productId,
    required String reason,
  }) async {
    try {
      await _client.post<dynamic>(
        AppStrings.productReportURL(productId.toString()),
        data: <String, dynamic>{
          'reason': reason,
        },
      );
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<List<ReviewModel>> getProductReviews({
    required int productId,
  }) async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(
        AppStrings.reviewsURL,
        queryParameters: <String, dynamic>{'product': productId},
      );

      if (response.data is List<dynamic>) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map((Map<String, dynamic> item) =>
                ReviewModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }

      if (response.data == null) {
        return <ReviewModel>[];
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<ReviewModel> createReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    try {
      final Response<dynamic> response = await _client.post<dynamic>(
        AppStrings.reviewsURL,
        data: <String, dynamic>{
          'product': productId,
          'rating': rating,
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return ReviewModel.fromJson(Map<String, dynamic>.from(data));
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<ReviewModel> updateReview({
    required int reviewId,
    required int rating,
    String? comment,
  }) async {
    try {
      final Response<dynamic> response = await _client.put<dynamic>(
        AppStrings.reviewDetailURL(reviewId.toString()),
        data: <String, dynamic>{
          'rating': rating,
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return ReviewModel.fromJson(Map<String, dynamic>.from(data));
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  List<ProductModel> _parseProductList(dynamic payload) {
    if (payload is List<dynamic>) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> item) =>
              ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (payload == null) {
      return <ProductModel>[];
    }
    throw const ServerException('Invalid response structure');
  }

  ProductModel _parseProduct(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return ProductModel.fromJson(Map<String, dynamic>.from(payload));
    }
    if (payload == null) {
      throw const ServerException('Empty response body');
    }
    throw const ServerException('Invalid response structure');
  }

  @override
  Future<ProductModel> createProduct({
    required String name,
    required String description,
    required String price,
    required String type,
    required int category,
    String? duration,
    List<String>? images,
  }) async {
    try {
      final Map<String, dynamic> data = <String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
        'type': type,
        'category': category,
        if (duration != null && duration.isNotEmpty) 'duration': duration,
      };

      final Response<dynamic> response = await _client.post<dynamic>(
        endpoint,
        data: data,
      );

      return _parseProduct(response.data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  Map<String, dynamic>? _buildQuery({
    String? search,
    String? ordering,
  }) {
    final Map<String, dynamic> query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (ordering != null && ordering.isNotEmpty) {
      query['ordering'] = ordering;
    }
    return query.isEmpty ? null : query;
  }
}
