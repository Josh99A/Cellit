import 'package:intl/intl.dart';

import '../constants/app_currencies.dart';

/// Currency Formatter dependent on the selected [AppCurrency]
///
/// The active currency is managed by CurrencyNotifier and defaults to [AppCurrencies.defaultCurrency]
class CurrencyFormatter {
  CurrencyFormatter._();

  static AppCurrency currency = AppCurrencies.defaultCurrency;

  static String get _symbolPrefix => currency.symbol.length > 1 ? '${currency.symbol} ' : currency.symbol;

  static String format(num data, {int? decimalDigits}) {
    return NumberFormat.currency(
      locale: 'en',
      symbol: _symbolPrefix,
      decimalDigits: decimalDigits ?? currency.decimalDigits,
    ).format(data);
  }

  static String compact(num data, {int? decimalDigits, bool withSymbol = true}) {
    return NumberFormat.compactCurrency(
      locale: 'en',
      symbol: withSymbol ? _symbolPrefix : '',
      decimalDigits: decimalDigits ?? currency.decimalDigits,
    ).format(data);
  }

  static String withoutSymbol(num data, {int? decimalDigits}) {
    return NumberFormat.currency(
      locale: 'en',
      symbol: '',
      decimalDigits: decimalDigits ?? currency.decimalDigits,
    ).format(data);
  }

  static String currencySymbol() {
    return currency.symbol;
  }
}
