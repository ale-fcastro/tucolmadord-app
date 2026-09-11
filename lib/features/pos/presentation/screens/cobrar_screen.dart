import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../../domain/entities/sale.dart';
import '../cubit/pos_cubit.dart';
import '../cubit/pos_state.dart';
import 'sale_complete_screen.dart';

class CobrarScreen extends StatelessWidget {
  const CobrarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PosCubit>();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocBuilder<PosCubit, PosState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 16, 4),
                  child: Row(
                    children: [
                      IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
                      const Text('Cobrar', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                  child: Column(
                    children: [
                      const Text('Total a cobrar', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
                      Text(Money.label(state.cartTotal), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
                      Text('${state.cartCount} artículos', style: const TextStyle(fontSize: 12.5, color: Color(0x80201F1D))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppDecorations.cardShadow),
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        _MethodTab(
                          label: 'Efectivo',
                          selected: state.paymentMethod == PaymentMethod.efectivo,
                          onTap: () => cubit.selectPaymentMethod(PaymentMethod.efectivo),
                        ),
                        _MethodTab(
                          label: 'Transferencia',
                          selected: state.paymentMethod == PaymentMethod.transferencia,
                          onTap: () => cubit.selectPaymentMethod(PaymentMethod.transferencia),
                        ),
                        _MethodTab(
                          label: 'Fiado',
                          selected: state.paymentMethod == PaymentMethod.fiado,
                          onTap: () => cubit.selectPaymentMethod(PaymentMethod.fiado),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: switch (state.paymentMethod) {
                      PaymentMethod.efectivo => _EfectivoSection(state: state, cubit: cubit),
                      PaymentMethod.transferencia => Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppDecorations.cardShadow),
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Confirma cuando recibas la transferencia por ${Money.label(state.cartTotal)}.',
                            style: const TextStyle(fontSize: 13, color: Color(0x99201F1D), height: 1.5),
                          ),
                        ),
                      PaymentMethod.fiado => _FiadoSection(state: state, cubit: cubit),
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.canConfirmPayment ? AppColors.primary : const Color(0xFFCBD3E8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: state.canConfirmPayment
                          ? () async {
                              await cubit.confirmSale();
                              if (!context.mounted) return;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => BlocProvider.value(value: cubit, child: const SaleCompleteScreen())),
                              );
                            }
                          : null,
                      child: const Text('CONFIRMAR COBRO', style: TextStyle(fontWeight: FontWeight.w800)),
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

class _MethodTab extends StatelessWidget {
  const _MethodTab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(11)),
          child: Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF201F1D))),
        ),
      ),
    );
  }
}

class _EfectivoSection extends StatelessWidget {
  const _EfectivoSection({required this.state, required this.cubit});
  final PosState state;
  final PosCubit cubit;

  @override
  Widget build(BuildContext context) {
    final quick = [state.cartTotal, 100, 200, 500];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Monto recibido', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.6,
          children: quick.map((v) {
            final selected = state.receivedAmount == v;
            return GestureDetector(
              onTap: () => cubit.setReceivedAmount(v.toDouble()),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(11), boxShadow: AppDecorations.cardShadow),
                child: Text(Money.label(v), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF201F1D))),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        const Text('Otro monto', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: AppDecorations.cardShadow),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            key: ValueKey(state.receivedAmount),
            controller: TextEditingController(text: state.receivedAmount > 0 ? state.receivedAmount.toStringAsFixed(0) : ''),
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(border: InputBorder.none, prefixText: 'RD\$  ', hintText: '0'),
            onChanged: (v) => cubit.setReceivedAmount(double.tryParse(v) ?? 0),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: AppDecorations.cardShadow),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cambio', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0x8C201F1D))),
              Text(Money.label(state.changeAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.success)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FiadoSection extends StatelessWidget {
  const _FiadoSection({required this.state, required this.cubit});
  final PosState state;
  final PosCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selecciona el cliente', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
        const SizedBox(height: 8),
        ...state.customers.map((c) {
          final selected = state.selectedCustomerId == c.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => cubit.selectCustomer(c.id),
              child: Container(
                decoration: BoxDecoration(color: selected ? AppColors.infoBg : Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: AppDecorations.cardShadow),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.fiadoBg,
                      child: Text(c.initial, style: const TextStyle(color: AppColors.fiado, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(c.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                    if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
