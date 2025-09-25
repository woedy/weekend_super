import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter({String currency = '₦'}) : _currency = currency;

  final String _currency;

  String format(double amount) {
    final NumberFormat formatter = NumberFormat.currency(symbol: _currency, decimalDigits: 2);
    return formatter.format(amount);
  }
}
