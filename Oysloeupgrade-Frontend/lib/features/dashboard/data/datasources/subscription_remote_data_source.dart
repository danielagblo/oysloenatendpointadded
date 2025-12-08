import 'package:dio/dio.dart';
import 'package:oysloe_mobile/core/constants/api.dart';
import 'package:oysloe_mobile/core/errors/exceptions.dart';
import 'package:oysloe_mobile/core/utils/api_helper.dart';

class SubscriptionRemoteDataSource {
  SubscriptionRemoteDataSource({required Dio client}) : _client = client;

  final Dio _client;

  Future<Map<String, dynamic>> fetchUserSubscription() async {
    try {
      final Response<dynamic> response =
          await _client.get<dynamic>(AppStrings.userSubscriptionsURL);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  Future<List<dynamic>> fetchAvailableSubscriptions() async {
    try {
      final Response<dynamic> response =
          await _client.get<dynamic>(AppStrings.subscriptionsURL);
      return List<dynamic>.from(response.data as List);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  Future<Map<String, dynamic>> createUserSubscription({
    required int subscriptionId,
    String? callbackUrl,
  }) async {
    try {
      final Response<dynamic> response = await _client.post<dynamic>(
        AppStrings.userSubscriptionsURL,
        data: <String, dynamic>{
          'subscription_id': subscriptionId,
          if (callbackUrl != null) 'callback_url': callbackUrl,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  Future<Map<String, dynamic>> updateUserSubscription({
    required String userSubscriptionId,
    int? subscriptionId,
    String? callbackUrl,
  }) async {
    final String endpoint =
        '${AppStrings.userSubscriptionsURL}$userSubscriptionId/';

    try {
      final Response<dynamic> response = await _client.patch<dynamic>(
        endpoint,
        data: <String, dynamic>{
          if (subscriptionId != null) 'subscription_id': subscriptionId,
          if (callbackUrl != null) 'callback_url': callbackUrl,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  Future<Map<String, dynamic>> initializePaystackPayment({
    required int subscriptionId,
    required String callbackUrl,
    String? email,
    String? amount,
  }) async {
    try {
      final Response<dynamic> response = await _client.post<dynamic>(
        '${AppStrings.paystackURL}initiate/',
        data: <String, dynamic>{
          'subscription_id': subscriptionId,
          'callback_url': callbackUrl,
          if (email != null) 'email': email,
          if (amount != null) 'amount': amount,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}
