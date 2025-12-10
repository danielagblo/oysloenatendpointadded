import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/subcategory_entity.dart';
import '../../../domain/usecases/get_subcategories_usecase.dart';
import 'subcategories_state.dart';

class SubcategoriesCubit extends Cubit<SubcategoriesState> {
  SubcategoriesCubit(this._getSubcategories)
      : super(const SubcategoriesState());

  final GetSubcategoriesUseCase _getSubcategories;

  Future<void> fetch({int? categoryId}) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: SubcategoriesStatus.loading,
        resetMessage: true,
      ),
    );

    final result = await _getSubcategories(
      GetSubcategoriesParams(categoryId: categoryId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubcategoriesStatus.failure,
          subcategories: const <SubcategoryEntity>[],
          message: failure.message,
        ),
      ),
      (subcategories) => emit(
        state.copyWith(
          status: SubcategoriesStatus.success,
          subcategories: subcategories,
          resetMessage: true,
        ),
      ),
    );
  }

  void clear() {
    emit(const SubcategoriesState());
  }
}
