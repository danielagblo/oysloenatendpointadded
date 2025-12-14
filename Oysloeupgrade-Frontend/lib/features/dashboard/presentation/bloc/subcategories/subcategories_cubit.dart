import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/subcategory_entity.dart';
import '../../../domain/usecases/get_subcategories_usecase.dart';
import 'subcategories_state.dart';

class SubcategoriesCubit extends Cubit<SubcategoriesState> {
  SubcategoriesCubit(this._getSubcategories)
      : super(const SubcategoriesState());

  final GetSubcategoriesUseCase _getSubcategories;

  Future<void> fetch({int? categoryId}) async {
    // Always fetch fresh data when categoryId changes
    // This ensures we get subcategories for the specific category
    print('SubcategoriesCubit.fetch() called with categoryId=$categoryId');

    emit(
      state.copyWith(
        status: SubcategoriesStatus.loading,
        resetMessage: true,
        subcategories: const <SubcategoryEntity>[], // Clear previous data
      ),
    );

    final result = await _getSubcategories(
      GetSubcategoriesParams(categoryId: categoryId),
    );
    
    result.fold(
      (failure) {
        print('SubcategoriesCubit.fetch() failed: ${failure.message}');
        emit(
          state.copyWith(
            status: SubcategoriesStatus.failure,
            subcategories: const <SubcategoryEntity>[],
            message: failure.message,
          ),
        );
      },
      (subcategories) {
        print('SubcategoriesCubit.fetch() success: ${subcategories.length} subcategories received');
        if (categoryId != null) {
          print('Subcategories for categoryId=$categoryId: ${subcategories.map((s) => '${s.name} (catId: ${s.categoryId})').join(", ")}');
        }
        emit(
          state.copyWith(
            status: SubcategoriesStatus.success,
            subcategories: subcategories,
            resetMessage: true,
          ),
        );
      },
    );
  }

  void clear() {
    emit(const SubcategoriesState());
  }
}
