import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/auth/presentation/cubit/auth_cubit.dart';
import 'core/auth/presentation/cubit/auth_state.dart';
import 'core/auth/presentation/screens/login_screen.dart';
import 'core/auth/presentation/screens/verify_email_screen.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/app_shell.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuColmadoRD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: BlocProvider(
        create: (_) => sl<AuthCubit>()..checkStoredSession(),
        child: const _AuthGate(),
      ),
    );
  }
}

/// Portero de autenticación — decide qué mostrar según el estado del
/// AuthCubit: spinner mientras se revisa la sesión guardada, login/registro
/// si no hay sesión, verificación de correo si hace falta, o el AppShell
/// (POS/inventario/fiados/etc., sin cambios) si ya hay una sesión válida.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is NeedsVerification) {
          return VerifyEmailScreen(email: state.email);
        }
        if (state is Authenticated) {
          return const AppShell();
        }
        // Unauthenticated y Authenticating comparten el flujo de
        // login/registro — LoginScreen muestra el estado de carga en su
        // propio botón vía BlocBuilder.
        return const LoginScreen();
      },
    );
  }
}
