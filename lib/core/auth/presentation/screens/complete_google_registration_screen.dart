import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/app_auth_screen.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Último paso del registro con Google — se llega acá cuando el correo de
/// Google autenticó bien pero no tenía cuenta todavía. Falta el nombre del
/// negocio y el teléfono para crearla; el gate en main.dart muestra esta
/// pantalla mientras el estado sea `NeedsGoogleBusinessInfo`.
class CompleteGoogleRegistrationScreen extends StatefulWidget {
  const CompleteGoogleRegistrationScreen({super.key, required this.state});

  final NeedsGoogleBusinessInfo state;

  @override
  State<CompleteGoogleRegistrationScreen> createState() =>
      _CompleteGoogleRegistrationScreenState();
}

class _CompleteGoogleRegistrationScreenState
    extends State<CompleteGoogleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _phoneCtrl.dispose();
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

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa un teléfono';
    return _serverError('phone');
  }

  void _submit(AuthCubit cubit) {
    setState(() => _fieldErrors = const {});
    if (!(_formKey.currentState?.validate() ?? false)) return;
    cubit.completeGoogleRegistration(
      registrationToken: widget.state.registrationToken,
      email: widget.state.email,
      fullName: widget.state.fullName,
      businessName: _businessNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is! NeedsGoogleBusinessInfo) return;
        if (state.fieldErrors != null && state.fieldErrors!.isNotEmpty) {
          setState(() => _fieldErrors = state.fieldErrors!);
          _formKey.currentState?.validate();
        } else if (state.error != null) {
          AppNotification.error(context, state.error!);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final loading =
              state is NeedsGoogleBusinessInfo && state.isSubmitting;
          return AppAuthScreen(
            appBar: AppBar(title: const Text('Un último paso')),
            formKey: _formKey,
            children: [
              const AppTitle('Registra tu colmado'),
              const SizedBox(height: 6),
              AppDescription(
                'Ya confirmamos ${widget.state.email} con Google. '
                'Solo falta el nombre de tu negocio y tu teléfono.',
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Nombre del negocio',
                controller: _businessNameCtrl,
                enabled: !loading,
                validator: _businessNameValidator,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Teléfono',
                controller: _phoneCtrl,
                enabled: !loading,
                keyboardType: TextInputType.phone,
                validator: _phoneValidator,
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
            ],
          );
        },
      ),
    );
  }
}
