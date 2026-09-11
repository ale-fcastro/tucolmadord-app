import '../../../../core/products/entities/product.dart';

enum ProductsFilter { all, lowStock, outOfStock, untracked }

sealed class ProductsState {
  const ProductsState();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  final List<Product> all;
  final String search;
  final ProductsFilter filter;

  const ProductsLoaded({required this.all, this.search = '', this.filter = ProductsFilter.all});

  List<Product> get visible {
    var list = all;
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    switch (filter) {
      case ProductsFilter.all:
        break;
      case ProductsFilter.lowStock:
        list = list.where((p) => p.isLowStock && !p.isOutOfStock).toList();
      case ProductsFilter.outOfStock:
        list = list.where((p) => p.isOutOfStock).toList();
      case ProductsFilter.untracked:
        list = list.where((p) => !p.trackStock).toList();
    }
    return list;
  }

  List<Product> get lowStockProducts => all.where((p) => p.isLowStock).toList();

  ProductsLoaded copyWith({List<Product>? all, String? search, ProductsFilter? filter}) {
    return ProductsLoaded(
      all: all ?? this.all,
      search: search ?? this.search,
      filter: filter ?? this.filter,
    );
  }
}
