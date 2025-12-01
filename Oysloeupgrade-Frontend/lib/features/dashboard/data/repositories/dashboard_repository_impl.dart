import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/account_delete_request_entity.dart';
import '../datasources/products_remote_data_source.dart';
import '../datasources/categories_remote_data_source.dart';
import '../datasources/categories_local_data_source.dart';
import '../datasources/alerts_remote_data_source.dart';
import '../datasources/account_delete_requests_remote_data_source.dart';
import '../models/category_model.dart';
import '../models/alert_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  static const Duration _categoriesCacheTtl = Duration(hours: 12);
  DashboardRepositoryImpl({
    required ProductsRemoteDataSource remoteDataSource,
    required CategoriesRemoteDataSource categoriesRemoteDataSource,
    required CategoriesLocalDataSource categoriesLocalDataSource,
    required AlertsRemoteDataSource alertsRemoteDataSource,
    required AccountDeleteRequestsRemoteDataSource
        accountDeleteRequestsRemoteDataSource,
    required Network network,
  })  : _remoteDataSource = remoteDataSource,
        _categoriesRemoteDataSource = categoriesRemoteDataSource,
        _categoriesLocalDataSource = categoriesLocalDataSource,
        _alertsRemoteDataSource = alertsRemoteDataSource,
        _accountDeleteRequestsRemoteDataSource =
            accountDeleteRequestsRemoteDataSource,
        _network = network;

  final ProductsRemoteDataSource _remoteDataSource;
  final CategoriesRemoteDataSource _categoriesRemoteDataSource;
  final CategoriesLocalDataSource _categoriesLocalDataSource;
  final AlertsRemoteDataSource _alertsRemoteDataSource;
  final AccountDeleteRequestsRemoteDataSource
      _accountDeleteRequestsRemoteDataSource;

  @override
  Future<Either<Failure, List<AccountDeleteRequestEntity>>>
      getAccountDeleteRequests() async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<AccountDeleteRequestEntity> items =
          (await _accountDeleteRequestsRemoteDataSource.getRequests())
              .cast<AccountDeleteRequestEntity>();
      return right(items);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected account delete requests fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, AccountDeleteRequestEntity>>
      createAccountDeleteRequest({String? reason}) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final AccountDeleteRequestEntity item =
          await _accountDeleteRequestsRemoteDataSource.createRequest(
        reason: reason,
      );
      return right(item);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected create account delete request failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, AccountDeleteRequestEntity>> getAccountDeleteRequest({
    required int id,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final AccountDeleteRequestEntity item =
          await _accountDeleteRequestsRemoteDataSource.getRequest(id);
      return right(item);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected get account delete request failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, AccountDeleteRequestEntity>>
      updateAccountDeleteRequest({
    required int id,
    String? reason,
    String? status,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final AccountDeleteRequestEntity item =
          await _accountDeleteRequestsRemoteDataSource.updateRequest(
        id,
        reason: reason,
        status: status,
      );
      return right(item);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected update account delete request failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccountDeleteRequest({
    required int id,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      await _accountDeleteRequestsRemoteDataSource.deleteRequest(id);
      return right(null);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected delete account delete request failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, AccountDeleteRequestEntity>>
      approveAccountDeleteRequest({required int id}) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final AccountDeleteRequestEntity item =
          await _accountDeleteRequestsRemoteDataSource.approveRequest(id);
      return right(item);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected approve account delete request failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, AccountDeleteRequestEntity>>
      rejectAccountDeleteRequest({required int id}) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final AccountDeleteRequestEntity item =
          await _accountDeleteRequestsRemoteDataSource.rejectRequest(id);
      return right(item);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected reject account delete request failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }
  final Network _network;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? ordering,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<ProductEntity> products = (await _remoteDataSource.getProducts(
        search: search,
        ordering: ordering,
      ))
          .cast<ProductEntity>();
      return right(products);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected products fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductDetail({
    required int id,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ProductEntity product =
          await _remoteDataSource.getProductDetail(id);
      return right(product);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected product detail fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getRelatedProducts({
    required int productId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<ProductEntity> products = (await _remoteDataSource
              .getRelatedProducts(productId: productId))
          .cast<ProductEntity>();
      return right(products);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected related products fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> markProductAsTaken({
    required int productId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ProductEntity product =
          await _remoteDataSource.markProductAsTaken(productId: productId);
      return right(product);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected mark product as taken failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> setProductStatus({
    required int productId,
    required String status,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ProductEntity product = await _remoteDataSource.setProductStatus(
        productId: productId,
        status: status,
      );
      return right(product);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected set product status failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct({
    required int productId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.deleteProduct(productId: productId);
      return right(null);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected delete product failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews({
    required int productId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<ReviewEntity> reviews =
          (await _remoteDataSource.getProductReviews(productId: productId))
              .cast<ReviewEntity>();
      return right(reviews);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected product reviews fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> createReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ReviewEntity review = await _remoteDataSource.createReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );
      return right(review);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected create review failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> updateReview({
    required int reviewId,
    required int rating,
    String? comment,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ReviewEntity review = await _remoteDataSource.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );
      return right(review);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected update review failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    bool forceRefresh = false,
  }) async {
    CachedCategories? cache;
    try {
      cache = await _categoriesLocalDataSource.readCategories();
    } on CacheException catch (error, stackTrace) {
      logError(
        'Unable to read cached categories',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final bool cacheHasData = cache?.categories.isNotEmpty ?? false;
    final DateTime? fetchedAt = cache?.fetchedAt;
    final bool cacheIsFresh = cacheHasData &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _categoriesCacheTtl;

    if (!forceRefresh && cacheIsFresh && cache != null) {
      return right(cache.categories.cast<CategoryEntity>());
    }

    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      if (cacheHasData && cache != null) {
        return right(cache.categories.cast<CategoryEntity>());
      }
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<CategoryModel> categories =
          await _categoriesRemoteDataSource.getCategories();
      try {
        await _categoriesLocalDataSource.cacheCategories(categories);
      } on CacheException catch (error, stackTrace) {
        logError(
          'Unable to cache categories',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return right(categories.cast<CategoryEntity>());
    } on ApiException catch (error) {
      if (cacheHasData && cache != null) {
        return right(cache.categories.cast<CategoryEntity>());
      }
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      if (cacheHasData && cache != null) {
        return right(cache.categories.cast<CategoryEntity>());
      }
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected categories fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      if (cacheHasData && cache != null) {
        return right(cache.categories.cast<CategoryEntity>());
      }
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<AlertEntity>>> getAlerts() async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<AlertModel> models = await _alertsRemoteDataSource.getAlerts();
      final List<AlertEntity> alerts = models
          .map<AlertEntity>((AlertModel model) => model)
          .toList()
        ..sort(
          (AlertEntity a, AlertEntity b) => b.createdAt.compareTo(a.createdAt),
        );
      return right(alerts);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected alerts fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> markAlertRead({
    required AlertEntity alert,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final AlertModel payload =
          AlertModel.fromEntity(alert.copyWith(isRead: true));
      await _alertsRemoteDataSource.markAlertRead(payload);
      return right(null);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected mark alert read failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlert({
    required int alertId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      await _alertsRemoteDataSource.deleteAlert(alertId);
      return right(null);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected delete alert failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    required String name,
    required String description,
    required String price,
    required String type,
    required int category,
    String? duration,
    List<String>? images,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ProductEntity product = await _remoteDataSource.createProduct(
        name: name,
        description: description,
        price: price,
        type: type,
        category: category,
        duration: duration,
        images: images,
      );
      return right(product);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected create product failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }
}
