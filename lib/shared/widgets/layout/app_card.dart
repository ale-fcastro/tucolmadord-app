import 'package:flutter/material.dart';

import '../../theme/app_decorations.dart';

/// Contenedor de card consistente — mismo radio y sombra en toda la app, y
/// el color sale del theme activo (no `Colors.white` fijo) para que se vea
/// bien tanto en modo claro como oscuro. Pasa [color] para variantes como
/// los banners semánticos (successBg, warningBg...).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDecorations.radius),
        boxShadow: color == null ? AppDecorations.cardShadow : null,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDecorations.radius),
      child: card,
    );
  }
}
