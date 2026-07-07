class TaxState {
  final double taxRate;

  const TaxState({required this.taxRate});

  TaxState copyWith({double? taxRate}) {
    return TaxState(
      taxRate: taxRate ?? this.taxRate,
    );
  }
}
