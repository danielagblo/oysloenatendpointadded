import 'package:intl/intl.dart';

class CurrencyFormatter {
  const CurrencyFormatter._({
    required this.locale,
    required this.symbol,
    required this.defaultDecimals,
  });

  final String locale;
  final String symbol;
  final int defaultDecimals;

  static const CurrencyFormatter ghana = CurrencyFormatter._(
    locale: 'en_GH',
    symbol: '₵ ',
    defaultDecimals: 0,
  );

  NumberFormat _formatter({int? decimalDigits}) => NumberFormat.currency(
        locale: locale,
        symbol: symbol,
        decimalDigits: decimalDigits ?? defaultDecimals,
      );

  String format(double value, {int? decimalDigits}) {
    return _formatter(decimalDigits: decimalDigits).format(value);
  }

  String formatRaw(String raw) {
    final double? parsed = double.tryParse(raw);
    if (parsed == null) {
      return '$symbol$raw';
    }

    final bool hasDecimals = parsed % 1 != 0;
    return format(
      parsed,
      decimalDigits: hasDecimals ? 2 : defaultDecimals,
    );
  }
}
