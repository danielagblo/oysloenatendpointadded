import 'package:oysloe_mobile/features/dashboard/data/datasources/subscription_remote_data_source.dart';

class SubscriptionRepository {
  SubscriptionRepository({required SubscriptionRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final SubscriptionRemoteDataSource _remoteDataSource;

  Future<Map<String, dynamic>> getUserSubscription() async {
    return _remoteDataSource.fetchUserSubscription();
  }

  Future<List<dynamic>> getAvailableSubscriptions() async {
    return _remoteDataSource.fetchAvailableSubscriptions();
  }

  Future<Map<String, dynamic>> createUserSubscription({
    required int subscriptionId,
    String? callbackUrl,
  }) async {
    return _remoteDataSource.createUserSubscription(
      subscriptionId: subscriptionId,
      callbackUrl: callbackUrl,
    );
  }

  Future<Map<String, dynamic>> updateUserSubscription({
    required String userSubscriptionId,
    int? subscriptionId,
    String? callbackUrl,
  }) async {
    return _remoteDataSource.updateUserSubscription(
      userSubscriptionId: userSubscriptionId,
      subscriptionId: subscriptionId,
      callbackUrl: callbackUrl,
    );
  }

  Future<Map<String, dynamic>> initializePaystackPayment({
    required int subscriptionId,
    required String callbackUrl,
    String? email,
    String? amount,
  }) async {
    return _remoteDataSource.initializePaystackPayment(
      subscriptionId: subscriptionId,
      callbackUrl: callbackUrl,
      email: email,
      amount: amount,
    );
  }
}
