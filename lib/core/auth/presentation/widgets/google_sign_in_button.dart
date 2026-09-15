import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../data/google_auth_service.dart';
import 'google_render_button.dart' as web;

/// Botón de "Continuar con Google". En Android/iOS/desktop es un botón
/// propio que dispara `GoogleAuthService.signIn()`; en Web muestra el botón
/// oficial del SDK de Google (Identity Services no permite UI propia ahí) y
/// escucha [GoogleAuthService.idTokenEvents] para enterarse cuándo terminó.
///
/// No se muestra nada si no hay Web Client ID configurado
/// (`GoogleAuthConfig.webClientId` vacío).
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({
    super.key,
    required this.googleAuthService,
    required this.onIdToken,
    this.enabled = true,
  });

  final GoogleAuthService googleAuthService;

  /// Se llama con el ID token apenas el usuario completa el login.
  final ValueChanged<String> onIdToken;

  final bool enabled;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  late final Future<void> _initialization;
  StreamSubscription<String>? _webSubscription;
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    _initialization = widget.googleAuthService.ensureInitialized();
    if (kIsWeb) {
      _webSubscription = widget.googleAuthService.idTokenEvents.listen(
        widget.onIdToken,
      );
    }
  }

  @override
  void dispose() {
    _webSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handlePressed() async {
    setState(() => _signingIn = true);
    try {
      final idToken = await widget.googleAuthService.signIn();
      if (idToken != null) widget.onIdToken(idToken);
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.googleAuthService.isConfigured) return const SizedBox.shrink();

    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 44,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        if (kIsWeb) {
          return SizedBox(
            height: 44,
            width: double.infinity,
            child: web.renderButton(),
          );
        }
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: (widget.enabled && !_signingIn) ? _handlePressed : null,
            child: _signingIn
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continuar con Google'),
          ),
        );
      },
    );
  }
}
