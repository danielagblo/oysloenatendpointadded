import 'package:equatable/equatable.dart';

class SubcategoryEntity extends Equatable {
  const SubcategoryEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    this.description,
  });

  final int id;
  final String name;
  final int categoryId;
  final String? description;

  @override
  List<Object?> get props => [id, name, categoryId, description];
}
