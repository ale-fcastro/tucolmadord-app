import 'package:flutter/material.dart';

/// Layout compartido por las pantallas de autenticación (login, registro,
/// recuperar contraseña, verificar correo). Antes cada una repetía a mano
/// `Scaffold > SafeArea > Form > SingleChildScrollView(padding fijo) >
/// Column(start)`, lo que deja el contenido pegado arriba y un hueco vacío
/// grande debajo del último botón en pantallas altas (tablets).
///
/// Este widget centra el contenido verticalmente cuando sobra espacio en el
/// viewport, y se vuelve scrolleable (sin recortar nada) cuando no alcanza
/// — formulario largo en un teléfono chico, o el teclado abierto.
class AppAuthScreen extends StatelessWidget {
  const AppAuthScreen({
    super.key,
    required this.formKey,
    required this.children,
    this.appBar,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final PreferredSizeWidget? appBar;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: crossAxisAlignment,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
