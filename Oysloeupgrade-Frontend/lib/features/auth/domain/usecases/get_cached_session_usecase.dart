import '../../../../core/usecase/usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class GetCachedSessionUseCase {
  GetCachedSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSessionEntity?> call(NoParams params) {
    return _repository.cachedSession();
  }
}
