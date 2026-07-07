import 'expense_entity.dart';
import 'ordered_product_entity.dart';
import 'transaction_entity.dart';

class ReportProductSales {
  final String name;
  final int quantity;
  final int revenue;

  const ReportProductSales({
    required this.name,
    required this.quantity,
    required this.revenue,
  });
}

class ReportSummaryEntity {
  final DateTime startDate;
  final DateTime endDate;
  final List<TransactionEntity> transactions;
  final List<ExpenseEntity> expenses;

  const ReportSummaryEntity({
    required this.startDate,
    required this.endDate,
    this.transactions = const [],
    this.expenses = const [],
  });

  int get transactionCount => transactions.length;

  int get totalRevenue => transactions.fold(0, (sum, trx) => sum + trx.totalAmount);

  // Legacy transactions created before tax support have subtotal 0; their total is the subtotal
  int get totalSubtotal =>
      transactions.fold(0, (sum, trx) => sum + (trx.subtotal > 0 ? trx.subtotal : trx.totalAmount));

  int get totalTax => transactions.fold(0, (sum, trx) => sum + trx.taxAmount);

  int get averageSale => transactionCount == 0 ? 0 : totalRevenue ~/ transactionCount;

  int get totalExpenses => expenses.fold(0, (sum, expense) => sum + expense.amount);

  int get totalCogs {
    int cogs = 0;

    for (final trx in transactions) {
      for (final product in trx.orderedProducts ?? const <OrderedProductEntity>[]) {
        cogs += (product.costPrice ?? 0) * product.quantity;
      }
    }

    return cogs;
  }

  bool get hasMissingCostPrices {
    return transactions.any(
      (trx) => (trx.orderedProducts ?? const <OrderedProductEntity>[]).any((product) => product.costPrice == null),
    );
  }

  int get grossProfit => totalSubtotal - totalCogs;

  int get netProfit => grossProfit - totalExpenses;

  List<ReportProductSales> get topProducts {
    final salesByProduct = <String, ({int quantity, int revenue})>{};

    for (final trx in transactions) {
      for (final product in trx.orderedProducts ?? const <OrderedProductEntity>[]) {
        final current = salesByProduct[product.name] ?? (quantity: 0, revenue: 0);
        salesByProduct[product.name] = (
          quantity: current.quantity + product.quantity,
          revenue: current.revenue + product.price * product.quantity,
        );
      }
    }

    final result = salesByProduct.entries
        .map((e) => ReportProductSales(name: e.key, quantity: e.value.quantity, revenue: e.value.revenue))
        .toList();

    result.sort((a, b) => b.revenue.compareTo(a.revenue));

    return result;
  }
}
