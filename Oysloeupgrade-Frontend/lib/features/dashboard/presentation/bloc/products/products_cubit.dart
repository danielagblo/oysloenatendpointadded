import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/get_products_usecase.dart';
import '../../../domain/usecases/create_product_usecase.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._getProducts, this._createProduct) : super(const ProductsState());

  final GetProductsUseCase _getProducts;
  final CreateProductUseCase _createProduct;

  Future<void> fetch({
    String? search,
    String? ordering,
  }) async {
    emit(
      state.copyWith(
        status: ProductsStatus.loading,
        resetMessage: true,
      ),
    );

    final result = await _getProducts(
      GetProductsParams(search: search, ordering: ordering),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductsStatus.failure,
          products: const <ProductEntity>[],
          message: failure.message,
        ),
      ),
      (products) => emit(
        state.copyWith(
          status: ProductsStatus.success,
          products: products,
          resetMessage: true,
        ),
      ),
    );
  }

  Future<void> createProduct(CreateProductParams params) async {
    final result = await _createProduct(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductsStatus.failure,
          message: failure.message,
        ),
      ),
      (product) {
        // Refresh the products list after successful creation
        fetch();
      },
    );
  }
}
