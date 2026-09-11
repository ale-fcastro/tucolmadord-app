import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/customers/entities/customer.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/customers/customers_repository.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../cubit/fiado_detail_cubit.dart';
import '../cubit/fiados_cubit.dart';
import '../widgets/pago_modal.dart';

class FiadoDetailScreen extends StatelessWidget {
  const FiadoDetailScreen({super.key, required this.customerId, required this.parentCubit});

  final String customerId;
  final FiadosCubit parentCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FiadoDetailCubit(sl<CustomersRepository>(), customerId),
      child: _FiadoDetailView(parentCubit: parentCubit),
    );
  }
}

class _FiadoDetailView extends StatelessWidget {
  const _FiadoDetailView({required this.parentCubit});
  final FiadosCubit parentCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiadoDetailCubit, FiadoDetailState>(
      builder: (context, state) {
        final cubit = context.read<FiadoDetailCubit>();
        if (state.loading || state.customer == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final customer = state.customer!;
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          parentCubit.load();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                      Text(customer.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDecorations.cardShadow),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Te debe', style: TextStyle(fontSize: 12.5, color: Color(0x8C201F1D))),
                            Text(
                              Money.label(customer.balance),
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: customer.balance > 0 ? AppColors.error : AppColors.success),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Historial', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppDecorations.cardShadow),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                          children: state.movements.isEmpty
                              ? [const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Sin movimientos', style: TextStyle(color: Color(0x80201F1D))))]
                              : state.movements.map((m) {
                                  final isPago = m.type == FiadoMovementType.pago;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0F201F1D)))),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(m.note ?? (isPago ? 'Pago recibido' : 'Compra'), style: const TextStyle(fontSize: 13))),
                                        Text(
                                          '${isPago ? '−' : '+'}${Money.label(m.amount)}',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isPago ? AppColors.success : AppColors.error),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
                          onPressed: () => showPagoModal(context, cubit),
                          child: const Text('REGISTRAR PAGO', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
