import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/constants/constants.dart';
import 'tax_state.dart';

final taxNotifierProvider = NotifierProvider<TaxNotifier, TaxState>(
  TaxNotifier.new,
);

class TaxNotifier extends Notifier<TaxState> {
  @override
  TaxState build() {
    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    final taxRate = sharedPreferences.getDouble(Constants.taxRateKey) ?? 0;

    return TaxState(taxRate: taxRate);
  }

  void changeTaxRate(double taxRate) async {
    final sharedPreferences = ref.read(sharedPreferencesProvider);
    await sharedPreferences.setDouble(Constants.taxRateKey, taxRate);

    state = TaxState(taxRate: taxRate);
  }
}
