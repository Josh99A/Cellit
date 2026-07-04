import 'package:equatable/equatable.dart';

class AppCurrency extends Equatable {
  final String code;
  final String symbol;
  final String name;
  final int decimalDigits;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.decimalDigits,
  });

  @override
  List<Object?> get props => [code, symbol, name, decimalDigits];
}

class AppCurrencies {
  // Prevents instantiation and extension
  AppCurrencies._();

  static const AppCurrency ugx = AppCurrency(code: 'UGX', symbol: 'UGX', name: 'Ugandan Shilling', decimalDigits: 0);

  static const List<AppCurrency> all = [
    ugx,
    AppCurrency(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling', decimalDigits: 2),
    AppCurrency(code: 'TZS', symbol: 'TSh', name: 'Tanzanian Shilling', decimalDigits: 0),
    AppCurrency(code: 'RWF', symbol: 'FRw', name: 'Rwandan Franc', decimalDigits: 0),
    AppCurrency(code: 'USD', symbol: '\$', name: 'US Dollar', decimalDigits: 2),
    AppCurrency(code: 'EUR', symbol: '€', name: 'Euro', decimalDigits: 2),
    AppCurrency(code: 'GBP', symbol: '£', name: 'British Pound', decimalDigits: 2),
    AppCurrency(code: 'NGN', symbol: '₦', name: 'Nigerian Naira', decimalDigits: 2),
    AppCurrency(code: 'ZAR', symbol: 'R', name: 'South African Rand', decimalDigits: 2),
    AppCurrency(code: 'INR', symbol: '₹', name: 'Indian Rupee', decimalDigits: 2),
  ];

  static const AppCurrency defaultCurrency = ugx;

  static AppCurrency byCode(String? code) {
    return all.where((c) => c.code == code).firstOrNull ?? defaultCurrency;
  }
}
