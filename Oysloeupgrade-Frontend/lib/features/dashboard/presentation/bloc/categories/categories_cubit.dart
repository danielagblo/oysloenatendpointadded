import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category_entity.dart';
import '../../../domain/usecases/get_categories_usecase.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._getCategories) : super(const CategoriesState());

  final GetCategoriesUseCase _getCategories;

  Future<void> fetch({bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (state.hasData && !forceRefresh) {
      return;
    }

    emit(
      state.copyWith(
        status: CategoriesStatus.loading,
        resetMessage: true,
      ),
    );

    final result = await _getCategories(forceRefresh: forceRefresh);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CategoriesStatus.failure,
          categories: const <CategoryEntity>[],
          message: failure.message,
        ),
      ),
      (categories) => emit(
        state.copyWith(
          status: CategoriesStatus.success,
          categories: categories,
          resetMessage: true,
        ),
      ),
    );
  }
}
