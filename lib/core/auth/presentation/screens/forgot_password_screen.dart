import 'package:flutter/material.dart';

import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/app_auth_screen.dart';
import '../../../../shared/widgets/text/app_text.dart';

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Pantalla de recuperación de contraseña — stub local, sin backend: la API
/// todavía no tiene un endpoint de reseteo de contraseña, así que solo
/// muestra un aviso de "en preparación" tras validar el correo. Refleja el
/// mismo comportamiento del dashboard web en /recuperar.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    if (!_emailRegex.hasMatch(v.trim())) return 'Correo inválido';
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    AppNotification.info(
      context,
      'Recuperación de contraseña en preparación. Escríbenos para soporte mientras se habilita.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppAuthScreen(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      formKey: _formKey,
      children: [
        const AppTitle('Recupera tu contraseña'),
        const SizedBox(height: 6),
        const AppDescription(
          'Te enviaremos instrucciones a tu correo para restablecerla.',
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Correo electrónico',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          validator: _emailValidator,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'ENVIAR INSTRUCCIONES',
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}
