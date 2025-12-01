import 'package:oysloe_mobile/features/dashboard/data/datasources/subscription_remote_data_source.dart';

class SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepository(this.remoteDataSource);

  Future<Map<String, dynamic>> getUserSubscription() async {
    return await remoteDataSource.fetchUserSubscription();
  }

  Future<List<dynamic>> getAvailableSubscriptions() async {
    return await remoteDataSource.fetchAvailableSubscriptions();
  }
}
