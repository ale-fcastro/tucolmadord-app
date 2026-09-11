import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/money.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_decorations.dart';
import '../cubit/fiados_cubit.dart';
import 'fiado_detail_screen.dart';

class FiadosScreen extends StatelessWidget {
  const FiadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiadosCubit, FiadosState>(
      builder: (context, state) {
        final cubit = context.read<FiadosCubit>();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  const Expanded(child: Text('Fiados', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700))),
                  ElevatedButton(
                    onPressed: () => _showAddCustomerDialog(context, cubit),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9)),
                    child: const Text('+ Cliente', style: TextStyle(fontSize: 12.5)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total pendiente', style: TextStyle(fontSize: 12.5, color: Color(0xFF8A2422))),
                    Text(Money.label(state.totalPending), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.error)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: AppDecorations.cardShadow),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  onChanged: cubit.setSearch,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Buscar cliente...', prefixIcon: Icon(Icons.search, size: 20)),
                ),
              ),
            ),
            Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: state.visible.length,
                      itemBuilder: (context, i) {
                        final c = state.visible[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => FiadoDetailScreen(customerId: c.id, parentCubit: cubit)),
                            ),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: AppDecorations.cardShadow),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 19,
                                    backgroundColor: AppColors.fiadoBg,
                                    child: Text(c.initial, style: const TextStyle(color: AppColors.fiado, fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                                  Text(
                                    Money.label(c.balance),
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.balance > 0 ? AppColors.error : AppColors.success),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomerDialog(BuildContext context, FiadosCubit cubit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo cliente'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                cubit.addCustomer(controller.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
