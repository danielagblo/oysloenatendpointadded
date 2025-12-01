import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:oysloe_mobile/core/usecase/register_params.dart';
import 'package:oysloe_mobile/features/auth/domain/usecases/register_usecase.dart';

import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
	final RegisterUseCase _registerUseCase;

	RegisterCubit(this._registerUseCase) : super(const RegisterState.initial());

	Future<void> submit(RegisterParams params) async {
		emit(const RegisterState.submitting());
		final result = await _registerUseCase(params);
		result.fold(
			(failure) => emit(RegisterState.failure(failure.message)),
			(session) => emit(RegisterState.success(session)),
		);
	}

	void reset() => emit(const RegisterState.initial());
}
