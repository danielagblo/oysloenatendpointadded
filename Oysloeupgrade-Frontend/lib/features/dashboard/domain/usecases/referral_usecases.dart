import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/referral_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetReferralInfoUseCase extends UseCase<ReferralEntity, NoParams> {
  GetReferralInfoUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ReferralEntity>> call(NoParams params) {
    return _repository.getReferralInfo();
  }
}

class GetReferralTransactionsUseCase
    extends UseCase<List<PointsTransactionEntity>, NoParams> {
  GetReferralTransactionsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<PointsTransactionEntity>>> call(
    NoParams params,
  ) {
    return _repository.getReferralTransactions();
  }
}

class RedeemCouponParams extends Equatable {
  const RedeemCouponParams({required this.code});

  final String code;

  @override
  List<Object> get props => <Object>[code];
}

class RedeemCouponUseCase extends UseCase<void, RedeemCouponParams> {
  RedeemCouponUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, void>> call(RedeemCouponParams params) {
    return _repository.redeemCoupon(code: params.code);
  }
}


