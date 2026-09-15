import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/business/data/business_profile_store.dart';
import '../../features/closing/presentation/screens/cierre_screen.dart';
import '../../features/expenses/presentation/screens/gasto_screen.dart';
import '../../features/fiados/presentation/cubit/fiados_cubit.dart';
import '../../features/fiados/presentation/screens/fiados_screen.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/pos/presentation/screens/vender_screen.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../../features/products/presentation/screens/inventario_screen.dart';
import '../../features/products/presentation/screens/product_new_screen.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_decorations.dart';
import '../di/service_locator.dart';
import '../sync/sync_scheduler.dart';

/// Shell de navegación principal — nav inferior + FAB con menú radial,
/// igual al diseño. Vive en core/ porque orquesta todas las features de
/// nivel superior; ninguna feature individual debería depender de él.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    // Best-effort: refresca el perfil del negocio (nombre/logo/RNC para la
    // factura) en segundo plano, sin bloquear el arranque si no hay red.
    sl<BusinessProfileStore>().load();
    // Empuja lo que haya en sync_queue hacia la API cada pocos minutos
    // mientras haya sesión activa (ver SyncScheduler).
    sl<SyncScheduler>().start();
  }

  @override
  void dispose() {
    sl<SyncScheduler>().stop();
    super.dispose();
  }

  void _refreshAll(BuildContext context) {
    context.read<HomeCubit>().load();
    context.read<ProductsCubit>().load();
    context.read<FiadosCubit>().load();
  }

  Future<void> _push(BuildContext context, Widget screen) async {
    setState(() => _menuOpen = false);
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (context.mounted) _refreshAll(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeCubit>()),
        BlocProvider(create: (_) => sl<ProductsCubit>()),
        BlocProvider(create: (_) => sl<FiadosCubit>()),
      ],
      child: Builder(builder: (context) {
        final screens = [
          HomeScreen(onGoInventarioLow: () => setState(() => _index = 1)),
          const InventarioScreen(),
          const FiadosScreen(),
          const MoreScreen(),
        ];

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: Stack(
              children: [
                IndexedStack(index: _index, children: screens),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !_menuOpen,
                    child: AnimatedOpacity(
                      opacity: _menuOpen ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: GestureDetector(
                        onTap: () => setState(() => _menuOpen = false),
                        child: Container(color: Colors.black.withValues(alpha: 0.55)),
                      ),
                    ),
                  ),
                ),
                _RadialItem(
                  bottom: 224,
                  center: true,
                  label: 'Vender',
                  icon: Icons.point_of_sale_outlined,
                  bg: AppColors.infoBg,
                  color: AppColors.primary,
                  visible: _menuOpen,
                  onTap: () => _push(context, const VenderScreen()),
                ),
                _RadialItem(
                  bottom: 172,
                  left: 24,
                  label: 'Gasto',
                  icon: Icons.attach_money,
                  bg: AppColors.warningBg,
                  color: AppColors.warning,
                  visible: _menuOpen,
                  onTap: () => _push(context, const GastoScreen()),
                ),
                _RadialItem(
                  bottom: 172,
                  right: 24,
                  label: 'Producto',
                  icon: Icons.inventory_2_outlined,
                  bg: AppColors.successBg,
                  color: AppColors.success,
                  visible: _menuOpen,
                  onTap: () => _push(
                    context,
                    BlocProvider.value(
                      value: context.read<ProductsCubit>(),
                      child: const ProductNewScreen(),
                    ),
                  ),
                ),
                _RadialItem(
                  bottom: 100,
                  left: 24,
                  label: 'Fiado',
                  icon: Icons.people_outline,
                  bg: AppColors.fiadoBg,
                  color: AppColors.fiado,
                  visible: _menuOpen,
                  onTap: () => setState(() {
                    _menuOpen = false;
                    _index = 2;
                  }),
                ),
                _RadialItem(
                  bottom: 100,
                  right: 24,
                  label: 'Cerrar día',
                  icon: Icons.bar_chart,
                  bg: AppColors.errorBg,
                  color: AppColors.error,
                  visible: _menuOpen,
                  onTap: () => _push(context, const CierreScreen()),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
              decoration: AppDecorations.topDivider(context).copyWith(color: Theme.of(context).colorScheme.surface),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(icon: Icons.home_outlined, label: 'Inicio', selected: _index == 0, onTap: () => setState(() => _index = 0)),
                  _NavItem(icon: Icons.inventory_2_outlined, label: 'Inventario', selected: _index == 1, onTap: () => setState(() => _index = 1)),
                  Semantics(
                    button: true,
                    label: _menuOpen ? 'Cerrar menú' : 'Abrir menú',
                    child: GestureDetector(
                      onTap: () => setState(() => _menuOpen = !_menuOpen),
                      child: Transform.translate(
                        offset: const Offset(0, -18),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 6))],
                          ),
                          child: Icon(_menuOpen ? Icons.close : Icons.add, color: Colors.white, size: _menuOpen ? 24 : 26),
                        ),
                      ),
                    ),
                  ),
                  _NavItem(icon: Icons.people_outline, label: 'Fiados', selected: _index == 2, onTap: () => setState(() => _index = 2)),
                  _NavItem(icon: Icons.more_horiz, label: 'Más', selected: _index == 3, onTap: () => setState(() => _index = 3)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label, seleccionado' : label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            width: 56,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadialItem extends StatelessWidget {
  const _RadialItem({
    required this.bottom,
    this.left,
    this.right,
    this.center = false,
    required this.label,
    required this.icon,
    required this.bg,
    required this.color,
    required this.visible,
    required this.onTap,
  });

  final double bottom;
  final double? left;
  final double? right;
  final bool center;
  final String label;
  final IconData icon;
  final Color bg;
  final Color color;
  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bubble = Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );

    final animated = IgnorePointer(
      ignoring: !visible,
      child: AnimatedScale(
        scale: visible ? 1 : 0.7,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: bubble,
        ),
      ),
    );

    if (center) {
      return Positioned(bottom: bottom, left: 0, right: 0, child: Center(child: animated));
    }
    return Positioned(bottom: bottom, left: left, right: right, child: animated);
  }
}
