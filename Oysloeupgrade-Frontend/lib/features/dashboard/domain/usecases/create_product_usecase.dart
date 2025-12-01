import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class CreateProductUseCase
    extends UseCase<ProductEntity, CreateProductParams> {
  CreateProductUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ProductEntity>> call(CreateProductParams params) {
    return _repository.createProduct(
      name: params.name,
      description: params.description,
      price: params.price,
      type: params.type,
      category: params.category,
      duration: params.duration,
      images: params.images,
    );
  }
}

class CreateProductParams extends Equatable {
  const CreateProductParams({
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.category,
    this.duration,
    this.images,
  });

  final String name;
  final String description;
  final String price;
  final String type;
  final int category;
  final String? duration;
  final List<String>? images;

  @override
  List<Object?> get props => <Object?>[
        name,
        description,
        price,
        type,
        category,
        duration,
        images,
      ];
}

