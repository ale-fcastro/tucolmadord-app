/// Formatea montos como "RD$ 1,234" — sin decimales, como en el negocio real.
/// Formato manual (sin `intl`) para no depender de datos de locale en runtime.
class Money {
  Money._();

  static String label(num amount) => 'RD\$ ${_grouped(amount.round())}';

  static String _grouped(int value) {
    final negative = value < 0;
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return negative ? '-$buffer' : buffer.toString();
  }
}
