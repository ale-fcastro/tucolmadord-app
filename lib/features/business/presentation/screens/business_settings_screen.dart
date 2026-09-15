import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_notification.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../../shared/widgets/text/app_text.dart';
import '../cubit/business_cubit.dart';
import '../cubit/business_state.dart';

/// Datos del negocio que se muestran en la factura: nombre, RNC/cédula,
/// dirección, teléfono y logo — para que el recibo identifique al colmado
/// del dueño y no a la app.
class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _rncCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  /// Logo elegido en esta sesión de edición, pendiente de guardar. `null`
  /// significa "sin cambios" — se sigue mostrando `_existingLogoBase64`.
  Uint8List? _pendingLogoBytes;
  bool _removeLogo = false;
  bool _hydrated = false;
  String? _existingLogoBase64;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rncCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _hydrate(BusinessState state) {
    if (_hydrated || state.profile == null) return;
    _hydrated = true;
    final profile = state.profile!;
    _nameCtrl.text = profile.name;
    _rncCtrl.text = profile.rnc ?? '';
    _addressCtrl.text = profile.address ?? '';
    _phoneCtrl.text = profile.phone ?? '';
    _existingLogoBase64 = profile.logoBase64;
  }

  Future<void> _pickLogo(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final file = await ImagePicker().pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _pendingLogoBytes = bytes;
        _removeLogo = false;
      });
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(context, 'No se pudo abrir la cámara/galería.');
    }
  }

  void _showLogoPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => _pickLogo(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () => _pickLogo(ImageSource.camera),
            ),
            if (_pendingLogoBytes != null || (_existingLogoBase64 != null && !_removeLogo))
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Quitar logo', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _pendingLogoBytes = null;
                    _removeLogo = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<BusinessCubit>();
    await cubit.save(
      name: _nameCtrl.text.trim(),
      rnc: _rncCtrl.text.trim().isEmpty ? null : _rncCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      logoBase64: _pendingLogoBytes != null ? base64Encode(_pendingLogoBytes!) : null,
      removeLogo: _removeLogo,
    );
    if (!mounted) return;
    final result = cubit.state;
    if (result.error != null) {
      AppNotification.error(context, result.error!);
      return;
    }
    setState(() {
      _pendingLogoBytes = null;
      _removeLogo = false;
      _existingLogoBase64 = result.profile?.logoBase64;
    });
    AppNotification.success(context, 'Datos del negocio guardados');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Datos del negocio',
      body: BlocConsumer<BusinessCubit, BusinessState>(
        listener: (context, state) => _hydrate(state),
        builder: (context, state) {
          _hydrate(state);
          if (state.loading && state.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 24 + MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  const AppDescription(
                    'Estos datos aparecen en el recibo/factura que reciben tus clientes.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: _showLogoPicker,
                    child: _LogoPreview(pendingBytes: _pendingLogoBytes, existingBase64: _removeLogo ? null : _existingLogoBase64),
                  ),
                  const SizedBox(height: 8),
                  const AppLabel('Toca para cambiar el logo'),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Nombre del negocio',
                    controller: _nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ponle un nombre a tu negocio' : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(label: 'RNC o cédula (opcional)', controller: _rncCtrl),
                  const SizedBox(height: 14),
                  AppTextField(label: 'Dirección (opcional)', controller: _addressCtrl),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Teléfono (opcional)',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(label: 'GUARDAR', isLoading: state.saving, onPressed: _save),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoPreview extends StatelessWidget {
  const _LogoPreview({this.pendingBytes, this.existingBase64});

  final Uint8List? pendingBytes;
  final String? existingBase64;

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (pendingBytes != null) {
      image = MemoryImage(pendingBytes!);
    } else if (existingBase64 != null) {
      try {
        image = MemoryImage(base64Decode(existingBase64!));
      } catch (_) {
        image = null;
      }
    }

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        shape: BoxShape.circle,
        image: image != null ? DecorationImage(image: image, fit: BoxFit.cover) : null,
      ),
      alignment: Alignment.center,
      child: image == null ? Icon(Icons.storefront_outlined, size: 36, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)) : null,
    );
  }
}
