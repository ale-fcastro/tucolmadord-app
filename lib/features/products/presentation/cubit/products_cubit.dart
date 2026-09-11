import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/products/entities/product.dart';
import '../../../../core/products/products_repository.dart';
import 'products_state.dart';

const _uuid = Uuid();

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository _repository;

  ProductsCubit(this._repository) : super(const ProductsLoading()) {
    load();
  }

  Future<void> load() async {
    final products = await _repository.getAll();
    emit(ProductsLoaded(all: products));
  }

  void setSearch(String value) {
    final s = state;
    if (s is ProductsLoaded) emit(s.copyWith(search: value));
  }

  void setFilter(ProductsFilter filter) {
    final s = state;
    if (s is ProductsLoaded) emit(s.copyWith(filter: filter));
  }

  Future<void> addProduct({
    required String name,
    required double? price,
    required double? cost,
    required SellMode mode,
    required String category,
    required bool trackStock,
    required double? stock,
    required double? minStock,
  }) async {
    final now = DateTime.now();
    final product = Product(
      id: _uuid.v4(),
      name: name,
      price: price,
      cost: cost,
      mode: mode,
      category: category,
      isFrequent: false,
      trackStock: trackStock,
      stock: stock,
      minStock: minStock,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.insert(product);
    await load();
  }
}
