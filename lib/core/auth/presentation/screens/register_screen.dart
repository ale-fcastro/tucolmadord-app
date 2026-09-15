import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Pantalla de registro — crea el negocio + el usuario dueño. Al terminar
/// con éxito el AuthCubit pasa a NeedsVerification y el gate en main.dart
/// navega automáticamente a VerifyEmailScreen; esta pantalla no navega en
/// el camino feliz, solo hacia atrás (a LoginScreen) si el usuario cancela.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _ownerFullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerFullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _serverError(String field) {
    for (final entry in _fieldErrors.entries) {
      if (entry.key.toLowerCase() == field.toLowerCase()) {
        return entry.value.isNotEmpty ? entry.value.first : null;
      }
    }
    return null;
  }

  String? _businessNameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa el nombre del negocio';
    return _serverError('businessName');
  }

  String? _ownerFullNameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre completo';
    return _serverError('ownerFullName');
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    if (!_emailRegex.hasMatch(v.trim())) return 'Correo inválido';
    return _serverError('email');
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa una contraseña';
    if (v.length < 6) return 'Debe tener al menos 6 caracteres';
    return _serverError('password');
  }

  void _submit(AuthCubit cubit) {
    setState(() => _fieldErrors = const {});
    if (!(_formKey.currentState?.validate() ?? false)) return;
    cubit.register(
      businessName: _businessNameCtrl.text.trim(),
      ownerFullName: _ownerFullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is! Unauthenticated) return;
            if (state.fieldErrors != null && state.fieldErrors!.isNotEmpty) {
              setState(() => _fieldErrors = state.fieldErrors!);
              _formKey.currentState?.validate();
            } else if (state.error != null) {
              AppNotification.error(context, state.error!);
            }
          },
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final loading = state is Authenticating;
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppTitle('Registra tu colmado'),
                      const SizedBox(height: 6),
                      const AppDescription('Crea tu cuenta para empezar a usar TuColmadoRD.'),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'Nombre del negocio',
                        controller: _businessNameCtrl,
                        enabled: !loading,
                        validator: _businessNameValidator,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Nombre completo del dueño',
                        controller: _ownerFullNameCtrl,
                        enabled: !loading,
                        validator: _ownerFullNameValidator,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Correo electrónico',
                        controller: _emailCtrl,
                        enabled: !loading,
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Contraseña',
                        controller: _passwordCtrl,
                        enabled: !loading,
                        obscureText: true,
                        validator: _passwordValidator,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: 'Crear cuenta',
                          isLoading: loading,
                          enabled: !loading,
                          onPressed: () => _submit(cubit),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: loading ? null : () => Navigator.of(context).maybePop(),
                          child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                        ),
                      ),
                    ],
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
