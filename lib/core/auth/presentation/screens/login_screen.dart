import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/app_auth_screen.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/google_sign_in_button.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Pantalla de inicio de sesión — primera pantalla que ve un usuario sin
/// sesión guardada. Si las credenciales son válidas pero el correo no está
/// confirmado, AuthCubit.login pasa a NeedsVerification y el gate en
/// main.dart navega automáticamente a VerifyEmailScreen con el correo
/// precargado — no hace falta manejar ese caso acá.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    if (!_emailRegex.hasMatch(v.trim())) return 'Correo inválido';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
    return null;
  }

  void _submit(AuthCubit cubit) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    cubit.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated && state.error != null) {
          AppNotification.error(context, state.error!);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final loading = state is Authenticating;
          return AppAuthScreen(
            formKey: _formKey,
            children: [
              Image.asset('assets/images/logo-full.png', height: 56),
              const SizedBox(height: 20),
              const AppDescription('Inicia sesión para gestionar tu colmado.'),
              const SizedBox(height: 32),
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
                  label: 'Iniciar sesión',
                  isLoading: loading,
                  enabled: !loading,
                  onPressed: () => _submit(cubit),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              GoogleSignInButton(
                googleAuthService: sl(),
                enabled: !loading,
                onIdToken: (idToken) => cubit.loginWithGoogle(idToken: idToken),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: loading
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: loading
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
