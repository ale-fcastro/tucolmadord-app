import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/layout/app_auth_screen.dart';
import '../../../../shared/widgets/layout/app_card.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

const _resendCooldownSeconds = 60;

/// Pantalla de verificación de correo — se muestra automáticamente cuando
/// AuthCubit pasa a NeedsVerification (tras un registro exitoso, o tras un
/// login con correo todavía sin confirmar).
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  Timer? _cooldownTimer;
  int _cooldownRemaining = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownRemaining = _resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownRemaining--;
        if (_cooldownRemaining <= 0) timer.cancel();
      });
    });
  }

  String? _codeValidator(String? v) {
    final code = v?.trim() ?? '';
    if (code.isEmpty) return 'Ingresa el código';
    if (code.length != 6) return 'El código debe tener 6 dígitos';
    return null;
  }

  void _verify(AuthCubit cubit) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    cubit.verifyEmail(email: widget.email, code: _codeCtrl.text.trim());
  }

  void _resend(AuthCubit cubit) {
    if (_cooldownRemaining > 0) return;
    _startCooldown();
    cubit.resendVerification(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is! NeedsVerification) return;
        if (state.error != null) {
          AppNotification.error(context, state.error!);
        } else if (state.info != null) {
          AppNotification.success(context, state.info!);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final submitting = state is NeedsVerification && state.isSubmitting;
          return AppAuthScreen(
            appBar: AppBar(
              title: const Text('Verifica tu correo'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancelar',
                onPressed: () => cubit.logout(),
              ),
            ),
            formKey: _formKey,
            children: [
              const AppTitle('Confirma tu correo'),
              const SizedBox(height: 6),
              AppDescription(
                'Enviamos un código de 6 dígitos a ${widget.email}. Ingrésalo abajo para '
                'activar tu cuenta.',
              ),
              const SizedBox(height: 24),
              AppCard(
                child: TextFormField(
                  controller: _codeCtrl,
                  enabled: !submitting,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: '000000',
                  ),
                  validator: _codeValidator,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Verificar',
                  isLoading: submitting,
                  enabled: !submitting,
                  onPressed: () => _verify(cubit),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: (_cooldownRemaining > 0 || submitting)
                      ? null
                      : () => _resend(cubit),
                  child: Text(
                    _cooldownRemaining > 0
                        ? 'Reenviar código (${_cooldownRemaining}s)'
                        : 'Reenviar código',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
