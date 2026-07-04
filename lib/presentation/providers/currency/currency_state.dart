import '../../../core/constants/app_currencies.dart';

class CurrencyState {
  final AppCurrency currency;

  const CurrencyState({required this.currency});

  CurrencyState copyWith({AppCurrency? currency}) {
    return CurrencyState(
      currency: currency ?? this.currency,
    );
  }
}
