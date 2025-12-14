import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/entities/feature_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/account_delete_request_entity.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../datasources/products_remote_data_source.dart';
import '../datasources/categories_remote_data_source.dart';
import '../datasources/subcategories_remote_data_source.dart';
import '../datasources/features_remote_data_source.dart';
import '../datasources/locations_remote_data_source.dart';
import '../datasources/categories_local_data_source.dart';
import '../datasources/alerts_remote_data_source.dart';
import '../datasources/account_delete_requests_remote_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/referral_remote_data_source.dart';
import '../datasources/static_pages_remote_data_source.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../models/feature_model.dart';
import '../models/location_model.dart';
import '../models/alert_model.dart';
import '../../domain/entities/referral_entity.dart';
import '../../domain/entities/static_page_entity.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  static const Duration _categoriesCacheTtl = Duration(hours: 12);
  DashboardRepositoryImpl({
    required ProductsRemoteDataSource remoteDataSource,
    required CategoriesRemoteDataSource categoriesRemoteDataSource,
    required SubcategoriesRemoteDataSource subcategoriesRemoteDataSource,
    required FeaturesRemoteDataSource featuresRemoteDataSource,
    required LocationsRemoteDataSource locationsRemoteDataSource,
    required CategoriesLocalDataSource categoriesLocalDataSource,
    required AlertsRemoteDataSource alertsRemoteDataSource,
    required AccountDeleteRequestsRemoteDataSource
        accountDeleteRequestsRemoteDataSource,
    required ChatRemoteDataSource chatRemoteDataSource,
    required ReferralRemoteDataSource referralRemoteDataSource,
    required StaticPagesRemoteDataSource staticPagesRemoteDataSource,
    required AuthRepository authRepository,
    required Network network,
  })  : _remoteDataSource = remoteDataSource,
        _categoriesRemoteDataSource = categoriesRemoteDataSource,
        _subcategoriesRemoteDataSource = subcategoriesRemoteDataSource,
        _featuresRemoteDataSource = featuresRemoteDataSource,
        _locationsRemoteDataSource = locationsRemoteDataSource,
        _categoriesLocalDataSource = categoriesLocalDataSource,
        _alertsRemoteDataSource = alertsRemoteDataSource,
        _accountDeleteRequestsRemoteDataSource =
            accountDeleteRequestsRemoteDataSource,
        _chatRemoteDataSource = chatRemoteDataSource,
        _referralRemoteDataSource = referralRemoteDataSource,
        _staticPagesRemoteDataSource = staticPagesRemoteDataSource,
        _authRepository = authRepository,
        _network = network;

  final ProductsRemoteDataSource _remoteDataSource;
  final CategoriesRemoteDataSource _categoriesRemoteDataSource;
  final SubcategoriesRemoteDataSource _subcategoriesRemoteDataSource;
  final FeaturesRemoteDataSource _featuresRemoteDataSource;
  final LocationsRemoteDataSource _locationsRemoteDataSource;
  final CategoriesLocalDataSource _categoriesLocalDataSource;
  final AlertsRemoteDataSource _alertsRemoteDataSource;
  final AccountDeleteRequestsRemoteDataSource
      _accountDeleteRequestsRemoteDataSource;
  final ChatRemoteDataSource _chatRemoteDataSource;
  final ReferralRemoteDataSource _referralRemoteDataSource;
  final StaticPagesRemoteDataSource _staticPagesRemoteDataSource;
  final AuthRepository _authRepository;

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
  Future<Either<Failure, String>> getOrCreateChatRoomId({
    required int productId,
    String? userId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final String chatRoomId =
          await _chatRemoteDataSource.getOrCreateChatRoomId(
        productId: productId.toString(),
        userId: userId,
      );
      return right(chatRoomId);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected get or create chat room id failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ChatRoomEntity>>> getChatRooms({
    bool? isSupport,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<ChatRoomEntity> rooms =
          (await _chatRemoteDataSource.getChatRooms(isSupport: isSupport))
              .cast<ChatRoomEntity>();
      return right(rooms);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected chat rooms fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getChatMessages({
    required String chatRoomId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<ChatMessageEntity> messages =
          (await _chatRemoteDataSource.getMessages(chatRoomId: chatRoomId))
              .cast<ChatMessageEntity>();
      return right(messages);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected chat messages fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendChatMessage({
    required String chatRoomId,
    required String text,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ChatMessageEntity message = await _chatRemoteDataSource.sendMessage(
        chatRoomId: chatRoomId,
        text: text,
      );
      return right(message);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected send chat message failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> markChatRoomRead({
    required String chatRoomId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      await _chatRemoteDataSource.markChatRoomRead(chatRoomId: chatRoomId);
      return right(null);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected mark chat room read failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? ordering,
    int? sellerId,
    int? category,
    int? location,
    String? region,
    double? priceMin,
    double? priceMax,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<ProductEntity> products = (await _remoteDataSource.getProducts(
        search: search,
        ordering: ordering,
        sellerId: sellerId,
        category: category,
        location: location,
        region: region,
        priceMin: priceMin,
        priceMax: priceMax,
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
  Future<Either<Failure, List<ProductEntity>>> getUserProducts() async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      // Get current user profile to extract user ID
      final userProfileResult = await _authRepository.getProfile();

      // If we can't get the user profile, return empty list or error
      int? currentUserId;
      userProfileResult.fold(
        (failure) => null,
        (user) {
          // Try to parse user ID as int
          currentUserId = int.tryParse(user.id);
        },
      );

      if (currentUserId == null) {
        return left(const APIFailure('Unable to identify current user'));
      }

      // Fetch products filtered by current user's ID
      final List<ProductEntity> products = (await _remoteDataSource.getProducts(
        ordering: '-created_at',
        sellerId: currentUserId,
      ))
          .cast<ProductEntity>();

      // Client-side filter as safeguard to ensure only current user's products
      final userProducts = products
          .where((product) => product.sellerId == currentUserId)
          .toList();

      return right(userProducts);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected user products fetch failure',
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
      final List<ProductEntity> products =
          (await _remoteDataSource.getRelatedProducts(productId: productId))
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
  Future<Either<Failure, ProductEntity>> confirmMarkProductAsTaken({
    required int productId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ProductEntity product = await _remoteDataSource
          .confirmMarkProductAsTaken(productId: productId);
      return right(product);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected confirm mark product as taken failure',
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
  Future<Either<Failure, void>> reportProduct({
    required int productId,
    required String reason,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.reportProduct(
        productId: productId,
        reason: reason,
      );
      return right(null);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected product report failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> toggleFavourite({
    required int productId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ProductEntity product =
          await _remoteDataSource.toggleFavourite(productId: productId);
      return right(product);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected favourite toggle failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFavourites() async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<ProductEntity> items =
          (await _remoteDataSource.getFavourites()).cast<ProductEntity>();
      return right(items);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected favourites fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> submitFeedback({
    required int rating,
    String? comment,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.submitFeedback(
        rating: rating,
        comment: comment,
      );
      return right(null);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected feedback submission failure',
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
  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories({
    int? categoryId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<SubcategoryModel> subcategories =
          await _subcategoriesRemoteDataSource.getSubcategories(
        categoryId: categoryId,
      );
      return right(subcategories.cast<SubcategoryEntity>());
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected subcategories fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<FeatureEntity>>> getFeatures({
    int? subcategoryId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<FeatureModel> features =
          await _featuresRemoteDataSource.getFeatures(
        subcategoryId: subcategoryId,
      );

      return right(features.cast<FeatureEntity>());
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected features fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocations() async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<LocationModel> locations =
          await _locationsRemoteDataSource.getLocations();
      return right(locations.cast<LocationEntity>());
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected locations fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocationsByRegion(
      String region) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<LocationModel> locations =
          await _locationsRemoteDataSource.getLocationsByRegion(region);
      return right(locations.cast<LocationEntity>());
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected locations by region fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
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
    String? status,
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
        status: status,
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

  @override
  Future<Either<Failure, ProductEntity>> repostProduct({
    required int productId,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ProductEntity product = await _remoteDataSource.repostProduct(
        productId: productId,
      );
      return right(product);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected repost product failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct({
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
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ProductEntity product = await _remoteDataSource.updateProduct(
        productId: productId,
        name: name,
        description: description,
        price: price,
        type: type,
        category: category,
        duration: duration,
        images: images,
        status: status,
      );
      return right(product);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected update product failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ReferralEntity>> getReferralInfo() async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final ReferralEntity referral =
          await _referralRemoteDataSource.getReferralInfo();
      return right(referral);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected referral info fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<PointsTransactionEntity>>>
      getReferralTransactions() async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final List<PointsTransactionEntity> transactions =
          (await _referralRemoteDataSource.getReferralTransactions())
              .cast<PointsTransactionEntity>();
      return right(transactions);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected referral transactions fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> redeemCoupon({
    required String code,
  }) async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      await _referralRemoteDataSource.redeemCoupon(code);
      return right(null);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected coupon redeem failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, StaticPageEntity>> getPrivacyPolicy() async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final StaticPageEntity content =
          await _staticPagesRemoteDataSource.fetchPrivacyPolicy();
      return right(content);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected privacy policy fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, StaticPageEntity>> getTermsConditions() async {
    final bool isConnected = await _network.isConnected;
    if (!isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }

    try {
      final StaticPageEntity content =
          await _staticPagesRemoteDataSource.fetchTermsConditions();
      return right(content);
    } on ApiException catch (error) {
      return left(APIFailure(error.message));
    } on ServerException catch (error) {
      return left(ServerFailure(error.message));
    } catch (error, stackTrace) {
      logError(
        'Unexpected terms & conditions fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const ServerFailure('Unexpected error occurred'));
    }
  }
}
