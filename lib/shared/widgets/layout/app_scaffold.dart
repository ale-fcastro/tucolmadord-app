import 'package:flutter/material.dart';

/// Scaffold base para pantallas de feature: título consistente, back button
/// automático, y un slot para acciones — evita repetir el mismo AppBar en
/// cada pantalla.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = true,
    this.onBack,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;

  /// Lógica extra a correr al volver (por ejemplo refrescar la pantalla
  /// anterior) antes del pop. Si no se pasa, se usa el pop automático.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton && onBack != null ? BackButton(onPressed: onBack) : null,
        automaticallyImplyLeading: showBackButton && onBack == null,
        actions: actions,
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
