import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  /// Color de fondo distinto al primario del theme — por ejemplo el botón
  /// verde de "día cerrado" en la pantalla de cierre.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: color != null ? ElevatedButton.styleFrom(backgroundColor: color) : null,
      onPressed: (enabled && !isLoading) ? onPressed : null,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
                )
              : Text(label),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
            )
          : Text(label),
    );
  }
}
