import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/account_delete_request_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetAccountDeleteRequestsUseCase
    implements UseCase<List<AccountDeleteRequestEntity>, NoParams> {
  GetAccountDeleteRequestsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<AccountDeleteRequestEntity>>> call(
    NoParams params,
  ) {
    return _repository.getAccountDeleteRequests();
  }
}

class CreateAccountDeleteRequestParams {
  const CreateAccountDeleteRequestParams({this.reason});

  final String? reason;
}

class CreateAccountDeleteRequestUseCase implements UseCase<
    AccountDeleteRequestEntity, CreateAccountDeleteRequestParams> {
  CreateAccountDeleteRequestUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, AccountDeleteRequestEntity>> call(
    CreateAccountDeleteRequestParams params,
  ) {
    return _repository.createAccountDeleteRequest(reason: params.reason);
  }
}

class SingleAccountDeleteRequestParams {
  const SingleAccountDeleteRequestParams(this.id);

  final int id;
}

class GetAccountDeleteRequestUseCase implements UseCase<
    AccountDeleteRequestEntity, SingleAccountDeleteRequestParams> {
  GetAccountDeleteRequestUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, AccountDeleteRequestEntity>> call(
    SingleAccountDeleteRequestParams params,
  ) {
    return _repository.getAccountDeleteRequest(id: params.id);
  }
}

class UpdateAccountDeleteRequestParams {
  const UpdateAccountDeleteRequestParams({
    required this.id,
    this.reason,
    this.status,
  });

  final int id;
  final String? reason;
  final String? status;
}

class UpdateAccountDeleteRequestUseCase implements UseCase<
    AccountDeleteRequestEntity, UpdateAccountDeleteRequestParams> {
  UpdateAccountDeleteRequestUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, AccountDeleteRequestEntity>> call(
    UpdateAccountDeleteRequestParams params,
  ) {
    return _repository.updateAccountDeleteRequest(
      id: params.id,
      reason: params.reason,
      status: params.status,
    );
  }
}

class DeleteAccountDeleteRequestUseCase
    implements UseCase<void, SingleAccountDeleteRequestParams> {
  DeleteAccountDeleteRequestUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, void>> call(
    SingleAccountDeleteRequestParams params,
  ) {
    return _repository.deleteAccountDeleteRequest(id: params.id);
  }
}

class ApproveAccountDeleteRequestUseCase implements UseCase<
    AccountDeleteRequestEntity, SingleAccountDeleteRequestParams> {
  ApproveAccountDeleteRequestUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, AccountDeleteRequestEntity>> call(
    SingleAccountDeleteRequestParams params,
  ) {
    return _repository.approveAccountDeleteRequest(id: params.id);
  }
}

class RejectAccountDeleteRequestUseCase implements UseCase<
    AccountDeleteRequestEntity, SingleAccountDeleteRequestParams> {
  RejectAccountDeleteRequestUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, AccountDeleteRequestEntity>> call(
    SingleAccountDeleteRequestParams params,
  ) {
    return _repository.rejectAccountDeleteRequest(id: params.id);
  }
}


