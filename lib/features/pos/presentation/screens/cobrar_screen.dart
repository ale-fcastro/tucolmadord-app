import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/selectable_chip.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/inputs/app_boxed_field.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../../domain/entities/sale.dart';
import '../cubit/pos_cubit.dart';
import '../cubit/pos_state.dart';
import 'sale_complete_screen.dart';

class CobrarScreen extends StatefulWidget {
  const CobrarScreen({super.key});

  @override
  State<CobrarScreen> createState() => _CobrarScreenState();
}

class _CobrarScreenState extends State<CobrarScreen> {
  bool _confirming = false;

  Future<void> _confirmSale(PosCubit cubit) async {
    setState(() => _confirming = true);
    try {
      await cubit.confirmSale();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: const SaleCompleteScreen(),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(
        context,
        'No se pudo completar la venta. Intenta de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PosCubit>();
    return AppScaffold(
      title: 'Cobrar',
      body: BlocBuilder<PosCubit, PosState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                child: Column(
                  children: [
                    const AppLabel('Total a cobrar'),
                    AppAmount(Money.label(state.cartTotal)),
                    AppLabel('${state.cartCount} artículos'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppCard(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      _MethodTab(
                        label: 'Efectivo',
                        selected: state.paymentMethod == PaymentMethod.efectivo,
                        onTap: () =>
                            cubit.selectPaymentMethod(PaymentMethod.efectivo),
                      ),
                      _MethodTab(
                        label: 'Transferencia',
                        selected:
                            state.paymentMethod == PaymentMethod.transferencia,
                        onTap: () => cubit.selectPaymentMethod(
                          PaymentMethod.transferencia,
                        ),
                      ),
                      _MethodTab(
                        label: 'Fiado',
                        selected: state.paymentMethod == PaymentMethod.fiado,
                        onTap: () =>
                            cubit.selectPaymentMethod(PaymentMethod.fiado),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: switch (state.paymentMethod) {
                    PaymentMethod.efectivo => _EfectivoSection(
                      state: state,
                      cubit: cubit,
                    ),
                    PaymentMethod.transferencia => AppCard(
                      child: AppDescription(
                        'Confirma cuando recibas la transferencia por ${Money.label(state.cartTotal)}.',
                      ),
                    ),
                    PaymentMethod.fiado => _FiadoSection(
                      state: state,
                      cubit: cubit,
                    ),
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'CONFIRMAR COBRO',
                    enabled: state.canConfirmPayment,
                    isLoading: _confirming,
                    onPressed: () => _confirmSale(cubit),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MethodTab extends StatelessWidget {
  const _MethodTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: selected ? AppColors.onPrimary : onSurface),
          ),
        ),
      ),
    );
  }
}

class _EfectivoSection extends StatefulWidget {
  const _EfectivoSection({required this.state, required this.cubit});
  final PosState state;
  final PosCubit cubit;

  @override
  State<_EfectivoSection> createState() => _EfectivoSectionState();
}

class _EfectivoSectionState extends State<_EfectivoSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatAmount(widget.state.receivedAmount),
    );
  }

  @override
  void didUpdateWidget(covariant _EfectivoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo sincroniza cuando el monto cambió por una fuente externa (p.ej.
    // un chip de monto rápido) — si el cambio vino del propio campo, el
    // texto del controller ya coincide con el estado y no lo tocamos, para
    // no perder la posición del cursor en cada tecla.
    final controllerValue = double.tryParse(_controller.text) ?? 0;
    if (controllerValue != widget.state.receivedAmount) {
      _controller.text = _formatAmount(widget.state.receivedAmount);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) =>
      amount > 0 ? amount.toStringAsFixed(0) : '';

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = widget.cubit;
    final quick = [state.cartTotal, 100, 200, 500];
    final changeDue = state.changeDue;
    final insufficient = state.isPaymentInsufficient;
    final changeColor = insufficient
        ? AppColors.error
        : (changeDue > 0 ? AppColors.success : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLabel('Monto recibido'),
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
            return SelectableChip(
              label: Money.label(v),
              selected: selected,
              onTap: () => cubit.setReceivedAmount(v.toDouble()),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        const AppLabel('Otro monto'),
        const SizedBox(height: 6),
        AppBoxedField(
          controller: _controller,
          keyboardType: TextInputType.number,
          prefixText: 'RD\$  ',
          onChanged: (v) => cubit.setReceivedAmount(double.tryParse(v) ?? 0),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppLabel(insufficient ? 'Falta' : 'Cambio'),
              AppAmount(
                Money.label(insufficient ? -changeDue : changeDue),
                color: changeColor,
              ),
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
        const AppLabel('Selecciona el cliente'),
        const SizedBox(height: 8),
        ...state.customers.map((c) {
          final selected = state.selectedCustomerId == c.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              color: selected ? AppColors.infoBg : null,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              onTap: () => cubit.selectCustomer(c.id),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.fiadoBg,
                    child: Text(
                      c.initial,
                      style: const TextStyle(
                        color: AppColors.fiado,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: AppSubtitle(c.name)),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 18,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
