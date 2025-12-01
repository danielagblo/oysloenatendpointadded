import 'package:equatable/equatable.dart';

import '../../../domain/entities/category_entity.dart';

enum CategoriesStatus { initial, loading, success, failure }

class CategoriesState extends Equatable {
  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const <CategoryEntity>[],
    this.message,
  });

  final CategoriesStatus status;
  final List<CategoryEntity> categories;
  final String? message;

  bool get isLoading => status == CategoriesStatus.loading;
  bool get hasError => status == CategoriesStatus.failure;
  bool get hasData => categories.isNotEmpty;

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<CategoryEntity>? categories,
    String? message,
    bool resetMessage = false,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      message: resetMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, categories, message];
}
