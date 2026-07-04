import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utilities/currency_formatter.dart';
import 'currency_state.dart';

final currencyNotifierProvider = NotifierProvider<CurrencyNotifier, CurrencyState>(
  CurrencyNotifier.new,
);

class CurrencyNotifier extends Notifier<CurrencyState> {
  @override
  CurrencyState build() {
    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    final code = sharedPreferences.getString(Constants.selectedCurrencyCodeKey);
    final currency = AppCurrencies.byCode(code);

    CurrencyFormatter.currency = currency;

    return CurrencyState(currency: currency);
  }

  void changeCurrency(AppCurrency currency) async {
    final sharedPreferences = ref.read(sharedPreferencesProvider);
    await sharedPreferences.setString(Constants.selectedCurrencyCodeKey, currency.code);

    CurrencyFormatter.currency = currency;

    state = CurrencyState(currency: currency);
  }
}
