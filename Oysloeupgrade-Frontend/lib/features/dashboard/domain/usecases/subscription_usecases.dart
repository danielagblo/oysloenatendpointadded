import 'package:oysloe_mobile/features/dashboard/data/repositories/subscription_repository.dart';

class GetUserSubscriptionUseCase {
  final SubscriptionRepository repository;

  GetUserSubscriptionUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getUserSubscription();
  }
}

class GetAvailableSubscriptionsUseCase {
  final SubscriptionRepository repository;

  GetAvailableSubscriptionsUseCase(this.repository);

  Future<List<dynamic>> call() async {
    return await repository.getAvailableSubscriptions();
  }
}
