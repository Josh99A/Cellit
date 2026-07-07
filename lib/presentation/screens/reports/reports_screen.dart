import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/services/report/report_pdf_service.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../providers/main/main_notifier.dart';
import '../../providers/reports/reports_notifier.dart';
import '../../widgets/app_date_range_field.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/app_progress_indicator.dart';
import 'components/expense_card.dart';
import 'components/report_stat_card.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportsNotifierProvider.notifier).loadReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(reportsNotifierProvider.notifier);
    final state = ref.watch(reportsNotifierProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          actions: const [_ExportButton()],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Sales'),
              Tab(text: 'Profit & Loss'),
              Tab(text: 'Tax'),
              Tab(text: 'Expenses'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: AppDateRangeField(
                startDate: state.startDate,
                endDate: state.endDate,
                onChanged: notifier.onChangedDateRange,
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const AppProgressIndicator()
                  : const TabBarView(
                      children: [
                        _SalesSummaryTab(),
                        _ProfitLossTab(),
                        _TaxReportTab(),
                        _ExpensesTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends ConsumerWidget {
  const _ExportButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.picture_as_pdf_outlined),
      tooltip: 'Export PDF',
      onPressed: () {
        final state = ref.read(reportsNotifierProvider);
        final businessName = ref.read(mainNotifierProvider).user?.name;
        final tabIndex = DefaultTabController.of(context).index;

        final doc = switch (tabIndex) {
          0 => ReportPdfService.buildSalesSummaryPdf(state, businessName: businessName),
          2 => ReportPdfService.buildTaxReportPdf(state, businessName: businessName),
          // Profit & Loss export already includes the expense list
          _ => ReportPdfService.buildProfitAndLossPdf(state, businessName: businessName),
        };

        Printing.layoutPdf(onLayout: (format) => doc.save());
      },
    );
  }
}

class _SalesSummaryTab extends ConsumerWidget {
  const _SalesSummaryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ReportStatCard(
                  label: 'Revenue',
                  value: CurrencyFormatter.format(state.totalRevenue),
                ),
              ),
              const SizedBox(width: AppSizes.padding),
              Expanded(
                child: ReportStatCard(
                  label: 'Transactions',
                  value: '${state.transactionCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            children: [
              Expanded(
                child: ReportStatCard(
                  label: 'Average Sale',
                  value: CurrencyFormatter.format(state.averageSale),
                ),
              ),
              const SizedBox(width: AppSizes.padding),
              Expanded(
                child: ReportStatCard(
                  label: 'Tax Collected',
                  value: CurrencyFormatter.format(state.totalTax),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding * 1.5),
          Text(
            'Top Products',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.padding),
          if (state.topProducts.isEmpty)
            const AppEmptyState(subtitle: 'No sales in this period')
          else
            ...state.topProducts.take(10).map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: AppSizes.padding),
                    Text(
                      '${product.quantity}x',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: AppSizes.padding),
                    Text(
                      CurrencyFormatter.format(product.revenue),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ProfitLossTab extends ConsumerWidget {
  const _ProfitLossTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsNotifierProvider);
    final isProfitable = state.netProfit >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfitLossRow(label: 'Revenue (excl. tax)', value: state.totalSubtotal),
          _ProfitLossRow(label: 'Cost of Goods Sold', value: -state.totalCogs),
          _ProfitLossRow(label: 'Gross Profit', value: state.grossProfit, isBold: true),
          _ProfitLossRow(label: 'Expenses', value: -state.totalExpenses),
          const Divider(height: AppSizes.padding * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Profit',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                CurrencyFormatter.format(state.netProfit),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isProfitable ? Colors.green : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          if (state.hasMissingCostPrices) ...[
            const SizedBox(height: AppSizes.padding * 1.5),
            Container(
              padding: const EdgeInsets.all(AppSizes.padding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18),
                  const SizedBox(width: AppSizes.padding / 1.5),
                  Expanded(
                    child: Text(
                      'Some sold products have no cost price recorded, so the actual profit may be lower than shown.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfitLossRow extends StatelessWidget {
  final String label;
  final int value;
  final bool isBold;

  const _ProfitLossRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: isBold ? FontWeight.bold : null,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            value < 0 ? '- ${CurrencyFormatter.format(-value)}' : CurrencyFormatter.format(value),
            style: style,
          ),
        ],
      ),
    );
  }
}

class _TaxReportTab extends ConsumerWidget {
  const _TaxReportTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsNotifierProvider);
    final taxedTransactions = state.transactions.where((trx) => trx.taxAmount > 0).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ReportStatCard(
                  label: 'Tax Collected',
                  value: CurrencyFormatter.format(state.totalTax),
                ),
              ),
              const SizedBox(width: AppSizes.padding),
              Expanded(
                child: ReportStatCard(
                  label: 'Taxable Sales',
                  value: CurrencyFormatter.format(state.totalSubtotal),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding * 1.5),
          Text(
            'Taxed Transactions (${taxedTransactions.length})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.padding),
          if (taxedTransactions.isEmpty)
            const AppEmptyState(subtitle: 'No tax collected in this period')
          else
            ...taxedTransactions.map((trx) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '#${trx.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: AppSizes.padding),
                    Text(
                      '${trx.taxRate}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: AppSizes.padding),
                    Text(
                      CurrencyFormatter.format(trx.taxAmount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ExpensesTab extends ConsumerWidget {
  const _ExpensesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsNotifierProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${CurrencyFormatter.format(state.totalExpenses)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppIconButton(
                icon: Icons.add_rounded,
                onTap: () async {
                  await context.push('/reports/expense-create');
                  ref.read(reportsNotifierProvider.notifier).loadReport();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.padding),
        Expanded(
          child: state.expenses.isEmpty
              ? const AppEmptyState(subtitle: 'No expenses in this period')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
                  itemCount: state.expenses.length,
                  itemBuilder: (context, index) {
                    return ExpenseCard(expense: state.expenses[index]);
                  },
                ),
        ),
      ],
    );
  }
}
