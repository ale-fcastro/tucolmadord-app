import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/products/entities/product.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../cubit/pos_cubit.dart';
import '../cubit/pos_state.dart';
import '../widgets/amount_modal.dart';
import '../widgets/cart_sheet.dart';
import '../widgets/weight_modal.dart';

const _categories = ['Frecuentes', 'Todos', 'Bebidas', 'Comida', 'Otros'];

class VenderScreen extends StatelessWidget {
  const VenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PosCubit>(),
      child: const _VenderView(),
    );
  }
}

class _VenderView extends StatelessWidget {
  const _VenderView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PosCubit>();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocBuilder<PosCubit, PosState>(
          builder: (context, state) {
            if (state.loading) return const Center(child: CircularProgressIndicator());
            return Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 8, 16, 4),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          ),
                          const Text('Vender', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: AppDecorations.cardShadow),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          onChanged: cubit.setSearch,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Buscar producto...',
                            prefixIcon: Icon(Icons.search, size: 20),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        children: _categories.map((c) {
                          final selected = state.search.isEmpty && state.category == c;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => cubit.setCategory(c),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(11),
                                  boxShadow: AppDecorations.cardShadow,
                                ),
                                child: Text(
                                  c,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: selected ? Colors.white : const Color(0xFF201F1D),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 9,
                          mainAxisSpacing: 9,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: state.visibleProducts.length,
                        itemBuilder: (context, i) {
                          final p = state.visibleProducts[i];
                          return _ProductTile(product: p, cubit: cubit);
                        },
                      ),
                    ),
                  ],
                ),
                if (state.cartHasItems)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: GestureDetector(
                      onTap: () => showCartSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Carrito (${state.cartCount})',
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
                            Text(Money.label(state.cartTotal),
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.cubit});
  final Product product;
  final PosCubit cubit;

  @override
  Widget build(BuildContext context) {
    final priceLabel = product.price != null ? Money.label(product.price!) : 'Variable';
    return GestureDetector(
      onTap: () {
        switch (product.mode) {
          case SellMode.unit:
            cubit.addUnitToCart(product);
          case SellMode.amount:
            showAmountModal(context, product: product, onConfirm: (amount) => cubit.addAmountToCart(product, amount));
          case SellMode.weight:
            showWeightModal(context, product: product, onConfirm: (qty) => cubit.addWeightToCart(product, qty));
        }
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: AppDecorations.cardShadow),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 28,
                  child: Text(product.name,
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.25)),
                ),
                const SizedBox(height: 2),
                Text(priceLabel, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
            if (product.isLowStock)
              Positioned(
                top: 0,
                right: 0,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
              ),
          ],
        ),
      ),
    );
  }
}
