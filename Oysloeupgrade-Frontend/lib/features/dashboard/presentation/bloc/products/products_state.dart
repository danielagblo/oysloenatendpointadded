import 'package:equatable/equatable.dart';

import '../../../domain/entities/product_entity.dart';

enum ProductsStatus { initial, loading, success, failure }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const <ProductEntity>[],
    this.message,
  });

  final ProductsStatus status;
  final List<ProductEntity> products;
  final String? message;

  bool get isLoading => status == ProductsStatus.loading;
  bool get hasError => status == ProductsStatus.failure;
  bool get hasData => products.isNotEmpty;

  ProductsState copyWith({
    ProductsStatus? status,
    List<ProductEntity>? products,
    String? message,
    bool resetMessage = false,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      message: resetMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, products, message];
}
