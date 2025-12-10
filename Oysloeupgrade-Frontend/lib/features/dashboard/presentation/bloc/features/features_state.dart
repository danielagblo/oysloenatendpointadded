import 'package:equatable/equatable.dart';

import '../../../domain/entities/feature_entity.dart';

enum FeaturesStatus { initial, loading, success, failure }

class FeaturesState extends Equatable {
  const FeaturesState({
    this.status = FeaturesStatus.initial,
    this.features = const <FeatureEntity>[],
    this.message,
  });

  final FeaturesStatus status;
  final List<FeatureEntity> features;
  final String? message;

  bool get isLoading => status == FeaturesStatus.loading;
  bool get hasError => status == FeaturesStatus.failure;
  bool get hasData => features.isNotEmpty;

  FeaturesState copyWith({
    FeaturesStatus? status,
    List<FeatureEntity>? features,
    String? message,
    bool resetMessage = false,
  }) {
    return FeaturesState(
      status: status ?? this.status,
      features: features ?? this.features,
      message: resetMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, features, message];
}
