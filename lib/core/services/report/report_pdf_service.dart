import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/report_summary_entity.dart';
import '../../utilities/currency_formatter.dart';
import '../../utilities/date_time_formatter.dart';

class ReportPdfService {
  ReportPdfService._();

  static pw.Document buildSalesSummaryPdf(ReportSummaryEntity summary, {String? businessName}) {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header('Sales Summary', summary, businessName),
          _statTable([
            ('Revenue', CurrencyFormatter.format(summary.totalRevenue)),
            ('Transactions', '${summary.transactionCount}'),
            ('Average Sale', CurrencyFormatter.format(summary.averageSale)),
            ('Tax Collected', CurrencyFormatter.format(summary.totalTax)),
          ]),
          pw.SizedBox(height: 24),
          _sectionTitle('Top Products'),
          _table(
            headers: ['Product', 'Qty', 'Revenue'],
            rows: summary.topProducts.map((product) {
              return [product.name, '${product.quantity}', CurrencyFormatter.format(product.revenue)];
            }).toList(),
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Document buildProfitAndLossPdf(ReportSummaryEntity summary, {String? businessName}) {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header('Profit & Loss', summary, businessName),
          _table(
            headers: ['Item', 'Amount'],
            rows: [
              ['Revenue (excl. tax)', CurrencyFormatter.format(summary.totalSubtotal)],
              ['Cost of Goods Sold', '- ${CurrencyFormatter.format(summary.totalCogs)}'],
              ['Gross Profit', CurrencyFormatter.format(summary.grossProfit)],
              ['Expenses', '- ${CurrencyFormatter.format(summary.totalExpenses)}'],
              ['Net Profit', CurrencyFormatter.format(summary.netProfit)],
            ],
          ),
          if (summary.hasMissingCostPrices) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Note: some sold products have no cost price recorded, so the actual profit may be lower than shown.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
          pw.SizedBox(height: 24),
          _sectionTitle('Expenses'),
          _table(
            headers: ['Date', 'Category', 'Description', 'Amount'],
            rows: summary.expenses.map((expense) {
              return [
                DateTimeFormatter.slashDate(expense.date),
                expense.category,
                expense.description ?? '-',
                CurrencyFormatter.format(expense.amount),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Document buildTaxReportPdf(ReportSummaryEntity summary, {String? businessName}) {
    final doc = pw.Document();
    final taxedTransactions = summary.transactions.where((trx) => trx.taxAmount > 0).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header('Tax Report', summary, businessName),
          _statTable([
            ('Tax Collected', CurrencyFormatter.format(summary.totalTax)),
            ('Taxable Sales', CurrencyFormatter.format(summary.totalSubtotal)),
          ]),
          pw.SizedBox(height: 24),
          _sectionTitle('Taxed Transactions'),
          _table(
            headers: ['Trx. ID', 'Date', 'Subtotal', 'Rate', 'Tax'],
            rows: taxedTransactions.map((trx) {
              return [
                '#${trx.id}',
                DateTimeFormatter.slashDate(trx.createdAt ?? ''),
                CurrencyFormatter.format(trx.subtotal),
                '${trx.taxRate}%',
                CurrencyFormatter.format(trx.taxAmount),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _header(String title, ReportSummaryEntity summary, String? businessName) {
    final range =
        '${DateTimeFormatter.slashDate(summary.startDate.toIso8601String())}'
        ' - ${DateTimeFormatter.slashDate(summary.endDate.toIso8601String())}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          businessName ?? 'Cellit POS',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(title, style: const pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 2),
        pw.Text(range, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Divider(),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _statTable(List<(String, String)> stats) {
    return _table(
      headers: ['Metric', 'Value'],
      rows: stats.map((stat) => [stat.$1, stat.$2]).toList(),
    );
  }

  static pw.Widget _table({required List<String> headers, required List<List<String>> rows}) {
    if (rows.isEmpty) {
      return pw.Text('No data for this period.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700));
    }

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: {
        for (int i = 1; i < headers.length; i++) i: pw.Alignment.centerRight,
      },
      cellAlignment: pw.Alignment.centerLeft,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    );
  }
}
