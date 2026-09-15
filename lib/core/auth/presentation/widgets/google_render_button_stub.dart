import 'package:flutter/widgets.dart';

/// Stub para plataformas no-Web — `google_sign_in_web` va detrás de un
/// import condicional porque solo existe en Web.
Widget renderButton() {
  throw StateError('renderButton solo está disponible en Web.');
}
