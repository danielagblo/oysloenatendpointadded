import 'package:dio/dio.dart';
import 'package:oysloe_mobile/core/constants/api.dart';

class SubscriptionRemoteDataSource {
  final Dio dio;

  SubscriptionRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> fetchUserSubscription() async {
    final response = await dio.get(AppStrings.userSubscriptionsURL);
    return response.data;
  }

  Future<List<dynamic>> fetchAvailableSubscriptions() async {
    final response = await dio.get(AppStrings.subscriptionsURL);
    return response.data;
  }
}
