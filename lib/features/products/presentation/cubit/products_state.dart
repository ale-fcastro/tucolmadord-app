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

  /// Productos que coinciden con el texto de búsqueda (sin aplicar el chip de filtro).
  List<Product> get _searched {
    if (search.isEmpty) return all;
    final q = search.toLowerCase();
    return all.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  List<Product> get visible {
    var list = _searched;
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

  // Conteos por categoría (respetan la búsqueda activa, no el chip seleccionado)
  // usados para mostrar "Bajo stock (3)" etc. en los chips de filtro.
  int get allCount => _searched.length;
  int get lowStockCount => _searched.where((p) => p.isLowStock && !p.isOutOfStock).length;
  int get outOfStockCount => _searched.where((p) => p.isOutOfStock).length;
  int get untrackedCount => _searched.where((p) => !p.trackStock).length;

  ProductsLoaded copyWith({List<Product>? all, String? search, ProductsFilter? filter}) {
    return ProductsLoaded(
      all: all ?? this.all,
      search: search ?? this.search,
      filter: filter ?? this.filter,
    );
  }
}
