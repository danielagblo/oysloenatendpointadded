import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? search,
    String? ordering,
    int? sellerId,
    int? category,
    int? location,
    String? region,
    double? priceMin,
    double? priceMax,
  });

  Future<ProductModel> getProductDetail(int id);

  Future<List<ProductModel>> getRelatedProducts({
    required int productId,
  });

  Future<ProductModel> markProductAsTaken({
    required int productId,
  });

  Future<ProductModel> confirmMarkProductAsTaken({
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

  Future<ProductModel> toggleFavourite({
    required int productId,
  });

  Future<List<ProductModel>> getFavourites();

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
    String? status,
  });

  Future<ProductModel> repostProduct({
    required int productId,
  });

  Future<ProductModel> updateProduct({
    required int productId,
    String? name,
    String? description,
    String? price,
    String? type,
    int? category,
    String? duration,
    List<String>? images,
    String? status,
  });

  Future<void> submitFeedback({
    required int rating,
    String? comment,
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
    int? sellerId,
    int? category,
    int? location,
    String? region,
    double? priceMin,
    double? priceMax,
  }) async {
    try {
      final queryParams = _buildQuery(
        search: search,
        ordering: ordering,
        sellerId: sellerId,
        category: category,
        location: location,
        region: region,
        priceMin: priceMin,
        priceMax: priceMax,
      );
      print('Fetching products from API with query params: $queryParams');
      final Response<dynamic> response = await _client.get<dynamic>(
        endpoint,
        queryParameters: queryParams,
      );
      print('Products API response received: ${response.data?.length ?? 0} items');
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
        data: <String, dynamic>{
          'product': productId,
        },
      );
      return _parseProduct(response.data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<ProductModel> confirmMarkProductAsTaken({
    required int productId,
  }) async {
    try {
      final Response<dynamic> response = await _client.post<dynamic>(
        AppStrings.confirmMarkProductAsTakenURL(productId.toString()),
        data: <String, dynamic>{},
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
  Future<ProductModel> toggleFavourite({required int productId}) async {
    try {
      await _client.post<dynamic>(
        AppStrings.productFavouriteURL(productId.toString()),
        data: const <String, dynamic>{},
      );

      // The favourite endpoint returns only a status. Fetch the updated product
      // detail to get fresh favourite counts and flags.
      final Response<dynamic> detailResponse = await _client.get<dynamic>(
        AppStrings.productDetailURL(productId.toString()),
      );
      return _parseProduct(detailResponse.data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<List<ProductModel>> getFavourites() async {
    try {
      final Response<dynamic> response =
          await _client.get<dynamic>(AppStrings.favouritesURL);
      return _parseProductList(response.data);
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
    String? status,
  }) async {
    try {
      final Map<String, dynamic> data = <String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
        'type': type,
        'category': category,
        if (duration != null && duration.isNotEmpty) 'duration': duration,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final FormData formData = FormData.fromMap(data);

      // Add images as multipart files
      if (images != null && images.isNotEmpty) {
        print('📸 Preparing to upload ${images.length} images');
        for (int i = 0; i < images.length; i++) {
          final String imagePath = images[i];
          if (imagePath.isEmpty) continue;

          try {
            if (kIsWeb) {
              final XFile xfile = XFile(imagePath);
              final List<int> bytes = await xfile.readAsBytes();
              String filename = xfile.name;
              if (filename.isEmpty) {
                final Uri uri = Uri.parse(imagePath);
                filename = uri.pathSegments.isNotEmpty
                    ? uri.pathSegments.last
                    : 'product_image_$i.jpg';
              }
              if (!filename.contains('.')) {
                filename = '$filename.jpg';
              }
              print('📸 Adding image $i: $filename (${bytes.length} bytes)');
              formData.files.add(
                MapEntry(
                  'image',
                  MultipartFile.fromBytes(
                    bytes,
                    filename: filename,
                  ),
                ),
              );
            } else {
              final String filename = imagePath.split(RegExp(r'[\/\\]')).last;
              print('📸 Adding image $i: $filename');
              formData.files.add(
                MapEntry(
                  'image',
                  await MultipartFile.fromFile(
                    imagePath,
                    filename:
                        filename.isEmpty ? 'product_image_$i.jpg' : filename,
                  ),
                ),
              );
            }
          } catch (error) {
            // Log the error but continue with other images
            print('❌ Failed to attach image $i: $error');
            // Rethrow to ensure the error is visible
            throw ApiException(
                'Failed to attach image ${i + 1}: ${error.toString()}');
          }
        }
        print('📸 Total images added to FormData: ${formData.files.length}');
      }

      print('📤 Sending product creation request to $endpoint');
      final Response<dynamic> response = await _client.post<dynamic>(
        endpoint,
        data: formData,
      );
      print('✅ Product created successfully. Response: ${response.statusCode}');

      return _parseProduct(response.data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<ProductModel> repostProduct({required int productId}) async {
    try {
      final Response<dynamic> response = await _client.post<dynamic>(
        AppStrings.repostProductURL(productId.toString()),
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
  Future<ProductModel> updateProduct({
    required int productId,
    String? name,
    String? description,
    String? price,
    String? type,
    int? category,
    String? duration,
    List<String>? images,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (price != null) data['price'] = price;
      if (type != null) data['type'] = type;
      if (category != null) data['category'] = category;
      if (duration != null) data['duration'] = duration;
      if (status != null) data['status'] = status;

      // Handle images if provided
      FormData? formData;
      if (images != null && images.isNotEmpty) {
        formData = FormData.fromMap(data);
        for (int i = 0; i < images.length; i++) {
          final imagePath = images[i];
          try {
            if (kIsWeb) {
              // For web, read bytes from URL
              final bytes = await _client.get<List<int>>(
                imagePath,
                options: Options(responseType: ResponseType.bytes),
              );
              final String filename = imagePath.split('/').last;
              formData.files.add(
                MapEntry(
                  'image',
                  MultipartFile.fromBytes(
                    bytes.data!,
                    filename: filename.isEmpty ? 'product_image_$i.jpg' : filename,
                  ),
                ),
              );
            } else {
              final String filename = imagePath.split(RegExp(r'[\/\\]')).last;
              formData.files.add(
                MapEntry(
                  'image',
                  await MultipartFile.fromFile(
                    imagePath,
                    filename:
                        filename.isEmpty ? 'product_image_$i.jpg' : filename,
                  ),
                ),
              );
            }
          } catch (error) {
            throw ApiException(
                'Failed to attach image ${i + 1}: ${error.toString()}');
          }
        }
      }

      final Response<dynamic> response = await _client.patch<dynamic>(
        AppStrings.productDetailURL(productId.toString()),
        data: formData ?? data,
      );
      return _parseProduct(response.data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<void> submitFeedback({
    required int rating,
    String? comment,
  }) async {
    try {
      await _client.post<dynamic>(
        AppStrings.feedbackURL,
        data: <String, dynamic>{
          'rating': rating,
          'message': comment != null && comment.trim().isNotEmpty
              ? comment.trim()
              : '',
        },
      );
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  Map<String, dynamic>? _buildQuery({
    String? search,
    String? ordering,
    int? sellerId,
    int? category,
    int? location,
    String? region,
    double? priceMin,
    double? priceMax,
  }) {
    final Map<String, dynamic> query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (ordering != null && ordering.isNotEmpty) {
      query['ordering'] = ordering;
    }
    if (sellerId != null) {
      query['owner'] = sellerId;
    }
    if (category != null) {
      query['category'] = category;
    }
    if (location != null) {
      query['location'] = location;
    }
    if (region != null && region.isNotEmpty) {
      query['location__region'] = region;
    }
    if (priceMin != null) {
      query['price__gte'] = priceMin;
    }
    if (priceMax != null) {
      query['price__lte'] = priceMax;
    }
    return query.isEmpty ? null : query;
  }
}
