import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/product_entity.dart';
import '../entities/review_entity.dart';
import '../entities/category_entity.dart';
import '../entities/alert_entity.dart';
import '../entities/account_delete_request_entity.dart';
import '../entities/chat_room_entity.dart';
import '../entities/chat_message_entity.dart';
import '../entities/account_delete_request_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? search,
    String? ordering,
  });

  Future<Either<Failure, ProductEntity>> getProductDetail({
    required int id,
  });

  Future<Either<Failure, List<ProductEntity>>> getRelatedProducts({
    required int productId,
  });

  Future<Either<Failure, ProductEntity>> markProductAsTaken({
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
  });

  /// Account delete requests

  /// Account delete requests
  Future<Either<Failure, List<AccountDeleteRequestEntity>>>
      getAccountDeleteRequests();

  Future<Either<Failure, AccountDeleteRequestEntity>> createAccountDeleteRequest({
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
  Future<Either<Failure, List<ChatRoomEntity>>> getChatRooms();

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
}
