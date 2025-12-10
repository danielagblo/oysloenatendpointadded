import 'package:equatable/equatable.dart';

import '../../../domain/entities/subcategory_entity.dart';

enum SubcategoriesStatus { initial, loading, success, failure }

class SubcategoriesState extends Equatable {
  const SubcategoriesState({
    this.status = SubcategoriesStatus.initial,
    this.subcategories = const <SubcategoryEntity>[],
    this.message,
  });

  final SubcategoriesStatus status;
  final List<SubcategoryEntity> subcategories;
  final String? message;

  bool get isLoading => status == SubcategoriesStatus.loading;
  bool get hasError => status == SubcategoriesStatus.failure;
  bool get hasData => subcategories.isNotEmpty;

  SubcategoriesState copyWith({
    SubcategoriesStatus? status,
    List<SubcategoryEntity>? subcategories,
    String? message,
    bool resetMessage = false,
  }) {
    return SubcategoriesState(
      status: status ?? this.status,
      subcategories: subcategories ?? this.subcategories,
      message: resetMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, subcategories, message];
}
