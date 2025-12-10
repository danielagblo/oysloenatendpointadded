import 'package:equatable/equatable.dart';

class FeatureEntity extends Equatable {
  const FeatureEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    this.description,
    this.options,
  });

  final int id;
  final String name;
  final int categoryId;
  final String? description;
  final List<String>? options;

  @override
  List<Object?> get props => [id, name, categoryId, description, options];
}
