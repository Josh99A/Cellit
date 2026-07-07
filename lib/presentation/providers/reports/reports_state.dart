import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/report_summary_entity.dart';
import '../../../domain/entities/transaction_entity.dart';

class ReportsState extends ReportSummaryEntity {
  final bool isLoading;

  const ReportsState({
    required super.startDate,
    required super.endDate,
    super.transactions,
    super.expenses,
    this.isLoading = false,
  });

  ReportsState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<TransactionEntity>? transactions,
    List<ExpenseEntity>? expenses,
    bool? isLoading,
  }) {
    return ReportsState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      transactions: transactions ?? this.transactions,
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
