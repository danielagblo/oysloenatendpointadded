import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/product_entity.dart';
import '../entities/review_entity.dart';
import '../entities/category_entity.dart';
import '../entities/subcategory_entity.dart';
import '../entities/feature_entity.dart';
import '../entities/location_entity.dart';
import '../entities/alert_entity.dart';
import '../entities/account_delete_request_entity.dart';
import '../entities/chat_room_entity.dart';
import '../entities/chat_message_entity.dart';
import '../entities/referral_entity.dart';
import '../entities/static_page_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? ordering,
    int? sellerId,
  });

  Future<Either<Failure, List<ProductEntity>>> getUserProducts();

  Future<Either<Failure, ProductEntity>> getProductDetail({
    required int id,
  });

  Future<Either<Failure, List<ProductEntity>>> getRelatedProducts({
    required int productId,
  });

  Future<Either<Failure, ProductEntity>> markProductAsTaken({
    required int productId,
  });

  Future<Either<Failure, ProductEntity>> confirmMarkProductAsTaken({
    required int productId,
  });

  Future<Either<Failure, ProductEntity>> setProductStatus({
    required int productId,
    required String status,
  });

  Future<Either<Failure, void>> deleteProduct({
    required int productId,
  });

  Future<Either<Failure, void>> reportProduct({
    required int productId,
    required String reason,
  });

  Future<Either<Failure, ProductEntity>> toggleFavourite({
    required int productId,
  });

  Future<Either<Failure, List<ProductEntity>>> getFavourites();

  Future<Either<Failure, void>> submitFeedback({
    required int rating,
    String? comment,
  });

  Future<Either<Failure, List<ReviewEntity>>> getProductReviews({
    required int productId,
  });

  Future<Either<Failure, ReviewEntity>> createReview({
    required int productId,
    required int rating,
    String? comment,
  });

  Future<Either<Failure, ReviewEntity>> updateReview({
    required int reviewId,
    required int rating,
    String? comment,
  });

  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    bool forceRefresh = false,
  });

  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories({
    int? categoryId,
  });

  Future<Either<Failure, List<FeatureEntity>>> getFeatures({
    int? subcategoryId,
  });

  Future<Either<Failure, List<LocationEntity>>> getLocations();

  Future<Either<Failure, List<LocationEntity>>> getLocationsByRegion(
      String region);

  Future<Either<Failure, List<AlertEntity>>> getAlerts();

  Future<Either<Failure, void>> markAlertRead({
    required AlertEntity alert,
  });

  Future<Either<Failure, void>> deleteAlert({
    required int alertId,
  });

  Future<Either<Failure, ProductEntity>> createProduct({
    required String name,
    required String description,
    required String price,
    required String type,
    required int category,
    String? duration,
    List<String>? images,
    String? status,
  });

  Future<Either<Failure, ProductEntity>> repostProduct({
    required int productId,
  });

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
  });

  /// Account delete requests

  /// Account delete requests
  Future<Either<Failure, List<AccountDeleteRequestEntity>>>
      getAccountDeleteRequests();

  Future<Either<Failure, AccountDeleteRequestEntity>>
      createAccountDeleteRequest({
    String? reason,
  });

  Future<Either<Failure, AccountDeleteRequestEntity>> getAccountDeleteRequest({
    required int id,
  });

  Future<Either<Failure, AccountDeleteRequestEntity>>
      updateAccountDeleteRequest({
    required int id,
    String? reason,
    String? status,
  });

  Future<Either<Failure, void>> deleteAccountDeleteRequest({
    required int id,
  });

  Future<Either<Failure, AccountDeleteRequestEntity>>
      approveAccountDeleteRequest({
    required int id,
  });

  Future<Either<Failure, AccountDeleteRequestEntity>>
      rejectAccountDeleteRequest({
    required int id,
  });

  /// Chat
  Future<Either<Failure, String>> getOrCreateChatRoomId({
    required int productId,
    String? userId,
  });

  Future<Either<Failure, List<ChatRoomEntity>>> getChatRooms({
    bool? isSupport,
  });

  Future<Either<Failure, List<ChatMessageEntity>>> getChatMessages({
    required String chatRoomId,
  });

  Future<Either<Failure, ChatMessageEntity>> sendChatMessage({
    required String chatRoomId,
    required String text,
  });

  Future<Either<Failure, void>> markChatRoomRead({
    required String chatRoomId,
  });

  /// Referral & Points
  Future<Either<Failure, ReferralEntity>> getReferralInfo();

  Future<Either<Failure, List<PointsTransactionEntity>>>
      getReferralTransactions();

  Future<Either<Failure, void>> redeemCoupon({
    required String code,
  });

  /// Static pages
  Future<Either<Failure, StaticPageEntity>> getPrivacyPolicy();
  Future<Either<Failure, StaticPageEntity>> getTermsConditions();
}
