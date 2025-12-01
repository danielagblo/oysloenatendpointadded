import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/login_params.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginUseCase, this._logoutUseCase)
      : super(const LoginState.initial());

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> submit(LoginParams params) async {
    if (state.isSubmitting) return;
    emit(const LoginState.submitting());
    final result = await _loginUseCase(params);
    result.fold(
      (failure) => emit(LoginState.failure(failure.message)),
      (session) => emit(LoginState.success(session)),
    );
  }

  Future<void> logout() async {
    final result = await _logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(LoginState.failure(failure.message)),
      (_) => emit(const LoginState.loggedOut()),
    );
  }

  void reset() => emit(const LoginState.initial());
}
