import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import 'product_new_screen.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Inventario', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ProductsCubit>(),
                              child: const ProductNewScreen(),
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                        ),
                        child: const Text('+ Producto', style: TextStyle(fontSize: 12.5)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: AppDecorations.cardShadow),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      onChanged: context.read<ProductsCubit>().setSearch,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Buscar producto...',
                        prefixIcon: Icon(Icons.search, size: 20),
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
                        _FilterChip(
                          label: 'Todos',
                          selected: state.filter == ProductsFilter.all,
                          onTap: () => context.read<ProductsCubit>().setFilter(ProductsFilter.all),
                        ),
                        _FilterChip(
                          label: 'Bajo stock',
                          selected: state.filter == ProductsFilter.lowStock,
                          onTap: () => context.read<ProductsCubit>().setFilter(ProductsFilter.lowStock),
                        ),
                        _FilterChip(
                          label: 'Sin stock',
                          selected: state.filter == ProductsFilter.outOfStock,
                          onTap: () => context.read<ProductsCubit>().setFilter(ProductsFilter.outOfStock),
                        ),
                        _FilterChip(
                          label: 'Sin control',
                          selected: state.filter == ProductsFilter.untracked,
                          onTap: () => context.read<ProductsCubit>().setFilter(ProductsFilter.untracked),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                Expanded(
                  child: switch (state) {
                    ProductsLoading() => const Center(child: CircularProgressIndicator()),
                    ProductsLoaded(:final visible) => visible.isEmpty
                        ? const Center(child: Text('Sin productos'))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                            itemCount: visible.length,
                            itemBuilder: (context, i) {
                              final p = visible[i];
                              final priceLabel = switch (p.mode) {
                                _ when p.price != null => Money.label(p.price!),
                                _ => 'Precio variable',
                              };
                              final String stockLabel;
                              final Color stockColor;
                              final Color stockBg;
                              if (!p.trackStock) {
                                stockLabel = 'Sin control';
                                stockColor = const Color(0xFF5B564E);
                                stockBg = const Color(0xFFF6F1E8);
                              } else if (p.isOutOfStock) {
                                stockLabel = 'Sin stock';
                                stockColor = AppColors.error;
                                stockBg = AppColors.errorBg;
                              } else if (p.isLowStock) {
                                stockLabel = 'Stock: ${p.stock!.toStringAsFixed(0)}';
                                stockColor = AppColors.warning;
                                stockBg = AppColors.warningBg;
                              } else {
                                stockLabel = 'Stock: ${p.stock?.toStringAsFixed(0) ?? '-'}';
                                stockColor = AppColors.success;
                                stockBg = AppColors.successBg;
                              }
                              return Container(
                                margin: const EdgeInsets.only(bottom: 1),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0x0F201F1D))),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(p.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 2),
                                          Text(priceLabel, style: const TextStyle(fontSize: 12.5, color: Color(0x80201F1D))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: stockBg, borderRadius: BorderRadius.circular(8)),
                                      child: Text(
                                        stockLabel,
                                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: stockColor),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(11),
            boxShadow: AppDecorations.cardShadow,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF201F1D),
            ),
          ),
        ),
      ),
    );
  }
}
