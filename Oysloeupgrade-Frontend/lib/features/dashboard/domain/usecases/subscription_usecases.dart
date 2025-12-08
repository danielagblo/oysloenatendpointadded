import 'package:oysloe_mobile/features/dashboard/data/repositories/subscription_repository.dart';

class GetUserSubscriptionUseCase {
  GetUserSubscriptionUseCase(this.repository);

  final SubscriptionRepository repository;

  Future<Map<String, dynamic>> call() async {
    return repository.getUserSubscription();
  }
}

class GetAvailableSubscriptionsUseCase {
  GetAvailableSubscriptionsUseCase(this.repository);

  final SubscriptionRepository repository;

  Future<List<dynamic>> call() async {
    return repository.getAvailableSubscriptions();
  }
}

class CreateUserSubscriptionParams {
  const CreateUserSubscriptionParams({
    required this.subscriptionId,
    this.callbackUrl,
  });

  final int subscriptionId;
  final String? callbackUrl;
}

class CreateUserSubscriptionUseCase {
  CreateUserSubscriptionUseCase(this.repository);

  final SubscriptionRepository repository;

  Future<Map<String, dynamic>> call(CreateUserSubscriptionParams params) async {
    return repository.createUserSubscription(
      subscriptionId: params.subscriptionId,
      callbackUrl: params.callbackUrl,
    );
  }
}

class UpdateUserSubscriptionParams {
  const UpdateUserSubscriptionParams({
    required this.userSubscriptionId,
    this.subscriptionId,
    this.callbackUrl,
  });

  final String userSubscriptionId;
  final int? subscriptionId;
  final String? callbackUrl;
}

class UpdateUserSubscriptionUseCase {
  UpdateUserSubscriptionUseCase(this.repository);

  final SubscriptionRepository repository;

  Future<Map<String, dynamic>> call(UpdateUserSubscriptionParams params) async {
    return repository.updateUserSubscription(
      userSubscriptionId: params.userSubscriptionId,
      subscriptionId: params.subscriptionId,
      callbackUrl: params.callbackUrl,
    );
  }
}

class InitializePaystackPaymentParams {
  const InitializePaystackPaymentParams({
    required this.subscriptionId,
    required this.callbackUrl,
    this.email,
    this.amount,
  });

  final int subscriptionId;
  final String callbackUrl;
  final String? email;
  final String? amount;
}

class InitializePaystackPaymentUseCase {
  InitializePaystackPaymentUseCase(this.repository);

  final SubscriptionRepository repository;

  Future<Map<String, dynamic>> call(InitializePaystackPaymentParams params) async {
    return repository.initializePaystackPayment(
      subscriptionId: params.subscriptionId,
      callbackUrl: params.callbackUrl,
      email: params.email,
      amount: params.amount,
    );
  }
}
