import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/products/entities/product.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../../domain/entities/cart_line.dart';
import '../cubit/pos_cubit.dart';
import '../cubit/pos_state.dart';
import '../screens/cobrar_screen.dart';
import 'amount_modal.dart';
import 'weight_modal.dart';

void _editLine(BuildContext context, PosCubit cubit, CartLine line) {
  final matches = cubit.state.products.where((p) => p.id == line.productId);
  if (matches.isEmpty) return;
  final product = matches.first;
  switch (line.mode) {
    case SellMode.weight:
      showWeightModal(
        context,
        product: product,
        initialQty: line.quantity,
        onConfirm: (qty) {
          cubit.removeLine(line.id);
          cubit.addWeightToCart(product, qty);
        },
      );
    case SellMode.amount:
      showAmountModal(
        context,
        product: product,
        initialAmount: line.lineTotal,
        onConfirm: (amount) {
          cubit.removeLine(line.id);
          cubit.addAmountToCart(product, amount);
        },
      );
    case SellMode.unit:
      break;
  }
}

void showCartSheet(BuildContext context) {
  final cubit = context.read<PosCubit>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) {
      return BlocProvider.value(
        value: cubit,
        child: BlocBuilder<PosCubit, PosState>(
          builder: (context, state) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: Row(
                      children: [
                        Expanded(child: AppTitle('Carrito (${state.cartCount})')),
                        GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Icon(Icons.close, size: 20, color: Theme.of(context).colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: state.cart.length,
                      itemBuilder: (context, i) {
                        final line = state.cart[i];
                        final row = Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: AppDecorations.rowDivider(context),
                          child: Row(
                            children: [
                              Expanded(child: AppSubtitle(line.name)),
                              if (line.isUnit)
                                Container(
                                  decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(AppDecorations.radius)),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => cubit.decrementLine(line.id),
                                        child: const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Icon(Icons.remove, size: 14, color: AppColors.primary),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 24,
                                        child: Text(line.quantity.toStringAsFixed(0),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                      ),
                                      GestureDetector(
                                        onTap: () => cubit.incrementLine(line.id),
                                        child: const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Icon(Icons.add, size: 14, color: AppColors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: () => cubit.removeLine(line.id),
                                  child: const AppLabel('Quitar', color: AppColors.error),
                                ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 62,
                                child: Text(Money.label(line.lineTotal),
                                    textAlign: TextAlign.right, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        );
                        if (line.isUnit) return row;
                        // Weight/amount lines: tap to reopen the modal pre-filled, instead of delete-only.
                        return GestureDetector(
                          onTap: () => _editLine(context, cubit, line),
                          child: row,
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                    decoration: AppDecorations.topDivider(context),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppLabel('TOTAL'),
                            AppTitle(Money.label(state.cartTotal)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: 'COBRAR ${Money.label(state.cartTotal)}',
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => BlocProvider.value(value: cubit, child: const CobrarScreen())),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
