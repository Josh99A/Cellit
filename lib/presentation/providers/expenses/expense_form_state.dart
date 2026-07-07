class ExpenseFormState {
  final String? category;
  final int? amount;
  final String? description;
  final String? date;
  final bool isLoaded;

  const ExpenseFormState({
    this.category,
    this.amount,
    this.description,
    this.date,
    this.isLoaded = false,
  });

  ExpenseFormState copyWith({
    String? category,
    int? amount,
    String? description,
    String? date,
    bool? isLoaded,
  }) {
    return ExpenseFormState(
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
