import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/products/entities/product.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/selectable_chip.dart';
import '../../../../shared/widgets/layout/app_empty_state.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import 'product_new_screen.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(BuildContext context, String value) {
    setState(() {}); // refresh clear-button visibility immediately
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      context.read<ProductsCubit>().setSearch(value);
    });
  }

  void _clearFilters(BuildContext context) {
    _debounce?.cancel();
    _searchCtrl.clear();
    context.read<ProductsCubit>()
      ..setSearch('')
      ..setFilter(ProductsFilter.all);
    setState(() {});
  }

  void _openProduct(BuildContext context, {Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProductsCubit>(),
          child: ProductNewScreen(product: product),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  const Expanded(child: AppHeadline('Inventario')),
                  PrimaryButton(
                    label: 'Producto',
                    icon: Icons.add,
                    onPressed: () => _openProduct(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              // AppSearchField doesn't expose a controller or a suffix slot, and
              // it isn't owned by this agent, so the debounced+clearable search
              // box is built locally here, matching its visual style.
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDecorations.radius),
                  boxShadow: AppDecorations.cardShadow,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (value) => _onSearchChanged(context, value),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Buscar producto...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _debounce?.cancel();
                              _searchCtrl.clear();
                              context.read<ProductsCubit>().setSearch('');
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
            ),
            if (state is ProductsLoaded)
              SizedBox(
                height: 40,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SelectableChip(
                        label: 'Todos (${state.allCount})',
                        selected: state.filter == ProductsFilter.all,
                        onTap: () => context.read<ProductsCubit>().setFilter(
                          ProductsFilter.all,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SelectableChip(
                        label: 'Bajo stock (${state.lowStockCount})',
                        selected: state.filter == ProductsFilter.lowStock,
                        onTap: () => context.read<ProductsCubit>().setFilter(
                          ProductsFilter.lowStock,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SelectableChip(
                        label: 'Sin stock (${state.outOfStockCount})',
                        selected: state.filter == ProductsFilter.outOfStock,
                        onTap: () => context.read<ProductsCubit>().setFilter(
                          ProductsFilter.outOfStock,
                        ),
                      ),
                    ),
                    SelectableChip(
                      label: 'Sin control (${state.untrackedCount})',
                      selected: state.filter == ProductsFilter.untracked,
                      onTap: () => context.read<ProductsCubit>().setFilter(
                        ProductsFilter.untracked,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: switch (state) {
                ProductsLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ProductsLoaded(:final visible, :final all) =>
                  visible.isEmpty
                      ? (all.isEmpty
                            ? AppEmptyState(
                                message:
                                    'Sin productos aún — agrega el primero',
                                icon: Icons.add_box_outlined,
                                actionLabel: 'Agregar producto',
                                onAction: () => _openProduct(context),
                              )
                            : AppEmptyState(
                                message: 'Sin resultados para tu búsqueda',
                                icon: Icons.search_off,
                                actionLabel: 'Limpiar filtros',
                                onAction: () => _clearFilters(context),
                              ))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                          itemCount: visible.length,
                          itemBuilder: (context, i) {
                            final p = visible[i];
                            final priceLabel = switch (p.mode) {
                              _ when p.price != null => Money.label(p.price!),
                              _ => 'Precio variable',
                            };
                            final stockDecimals = p.mode == SellMode.weight
                                ? 1
                                : 0;
                            final String stockLabel;
                            final Color stockColor;
                            final Color stockBg;
                            if (!p.trackStock) {
                              stockLabel = 'Sin control';
                              stockColor = const Color(0xFF5B564E);
                              stockBg = AppColors.backgroundLight;
                            } else if (p.isOutOfStock) {
                              stockLabel = 'Sin stock';
                              stockColor = AppColors.error;
                              stockBg = AppColors.errorBg;
                            } else if (p.isLowStock) {
                              stockLabel =
                                  'Stock: ${p.stock!.toStringAsFixed(stockDecimals)}';
                              stockColor = AppColors.warning;
                              stockBg = AppColors.warningBg;
                            } else {
                              stockLabel =
                                  'Stock: ${p.stock?.toStringAsFixed(stockDecimals) ?? '-'}';
                              stockColor = AppColors.success;
                              stockBg = AppColors.successBg;
                            }
                            return InkWell(
                              onTap: () => _openProduct(context, product: p),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 1),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: AppDecorations.rowDivider(context),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AppSubtitle(p.name),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              AppLabel(priceLabel),
                                              if (p.category.isNotEmpty) ...[
                                                const Text(
                                                  ' · ',
                                                  style: TextStyle(
                                                    color: Color(0xFF9A948A),
                                                    fontSize: 11.5,
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    p.category,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Color(0xFF9A948A),
                                                      fontSize: 11.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: stockBg,
                                        borderRadius: BorderRadius.circular(
                                          AppDecorations.radius,
                                        ),
                                      ),
                                      child: Text(
                                        stockLabel,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: stockColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              },
            ),
          ],
        );
      },
    );
  }
}
