import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/dashboard_repository.dart';

class UpdateProductUseCase extends UseCase<ProductEntity, UpdateProductParams> {
  UpdateProductUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, ProductEntity>> call(UpdateProductParams params) {
    return _repository.updateProduct(
      productId: params.productId,
      name: params.name,
      description: params.description,
      price: params.price,
      type: params.type,
      category: params.category,
      duration: params.duration,
      images: params.images,
      status: params.status,
    );
  }
}

class UpdateProductParams extends Equatable {
  const UpdateProductParams({
    required this.productId,
    this.name,
    this.description,
    this.price,
    this.type,
    this.category,
    this.duration,
    this.images,
    this.status,
  });

  final int productId;
  final String? name;
  final String? description;
  final String? price;
  final String? type;
  final int? category;
  final String? duration;
  final List<String>? images;
  final String? status;

  @override
  List<Object?> get props => <Object?>[
        productId,
        name,
        description,
        price,
        type,
        category,
        duration,
        images,
        status,
      ];
}

