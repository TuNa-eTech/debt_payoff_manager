import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/debt.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/timeline_projection.dart';
import '../../domain/entities/user_settings.dart';
import '../../l10n/app_localizations.dart';
import '../utils/formatters.dart';

enum ReportTimeRange { monthly, yearly, fullHistory }

extension ReportTimeRangeX on ReportTimeRange {
  String get fileStem => switch (this) {
    ReportTimeRange.monthly => 'monthly',
    ReportTimeRange.yearly => 'yearly',
    ReportTimeRange.fullHistory => 'full_history',
  };
}

class ReportGeneratorService {
  static const String _regularFontAsset = 'assets/fonts/Roboto-Regular.ttf';
  static const String _boldFontAsset = 'assets/fonts/Roboto-Bold.ttf';

  pw.ThemeData? _cachedTheme;

  /// Generates a PDF report containing the amortization table.
  /// Returns the raw byte array of the PDF document.
  Future<Uint8List> generateAmortizationReport({
    required List<Debt> debts,
    required Plan plan,
    required TimelineProjection projection,
    required UserSettings settings,
    required AppLocalizations l10n,
    ReportTimeRange range = ReportTimeRange.fullHistory,
  }) async {
    final pdf = pw.Document(theme: await _loadTheme());
    final filteredMonths = _filterMonths(projection.months, range);

    // Calculate totals from projection
    final totalPayment = filteredMonths.fold<int>(
      0,
      (sum, month) => sum + month.totalPaymentThisMonth,
    );
    final totalInterest = filteredMonths.fold<int>(
      0,
      (sum, month) => sum + month.totalInterestThisMonth,
    );

    final debtFreeDate = projection.months.isNotEmpty
        ? AppFormatters.formatMonthYear(
            DateTime.parse('${projection.months.last.yearMonth}-01'),
            localeCode: settings.localeCode,
          )
        : l10n.reportsPreviewNotAvailable;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(settings, l10n, range),
        footer: (context) => _buildFooter(context, l10n),
        build: (context) => [
          _buildSummaryCard(
            totalPayment: totalPayment,
            totalInterest: totalInterest,
            debtFreeDate: debtFreeDate,
            settings: settings,
            l10n: l10n,
          ),
          pw.SizedBox(height: 24),
          _buildAmortizationTable(filteredMonths, settings, l10n),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    UserSettings settings,
    AppLocalizations l10n,
    ReportTimeRange range,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.reportsPdfAppTitle,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${l10n.reportsPdfAmortizationTitle} - ${_rangeLabel(l10n, range)}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          '${l10n.reportsPdfGeneratedOnLabel} ${AppFormatters.formatDateTime(DateTime.now(), localeCode: settings.localeCode)}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, AppLocalizations l10n) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        l10n.reportsPdfPageXOfY(context.pageNumber, context.pagesCount),
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  pw.Widget _buildSummaryCard({
    required int totalPayment,
    required int totalInterest,
    required String debtFreeDate,
    required UserSettings settings,
    required AppLocalizations l10n,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem(
            label: l10n.reportsPreviewTotalPaid,
            value: AppFormatters.formatCents(
              totalPayment,
              currencyCode: settings.currencyCode,
              localeCode: settings.localeCode,
            ),
          ),
          _buildSummaryItem(
            label: l10n.reportsPreviewTotalInterest,
            value: AppFormatters.formatCents(
              totalInterest,
              currencyCode: settings.currencyCode,
              localeCode: settings.localeCode,
            ),
          ),
          _buildSummaryItem(
            label: l10n.reportsPreviewDebtFreeDate,
            value: debtFreeDate,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem({required String label, required String value}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildAmortizationTable(
    List<MonthProjection> months,
    UserSettings settings,
    AppLocalizations l10n,
  ) {
    final headers = [
      l10n.reportsPdfColMonth,
      l10n.reportsPdfColPayment,
      l10n.reportsPdfColPrincipal,
      l10n.reportsPdfColInterest,
      l10n.reportsPdfColBalance,
    ];

    final data = months.map((month) {
      return [
        AppFormatters.formatMonthYear(
          DateTime.parse('${month.yearMonth}-01'),
          localeCode: settings.localeCode,
        ),
        AppFormatters.formatCents(
          month.totalPaymentThisMonth,
          currencyCode: settings.currencyCode,
          localeCode: settings.localeCode,
        ),
        AppFormatters.formatCents(
          month.totalPaymentThisMonth - month.totalInterestThisMonth,
          currencyCode: settings.currencyCode,
          localeCode: settings.localeCode,
        ),
        AppFormatters.formatCents(
          month.totalInterestThisMonth,
          currencyCode: settings.currencyCode,
          localeCode: settings.localeCode,
        ),
        AppFormatters.formatCents(
          month.totalBalanceEndOfMonth,
          currencyCode: settings.currencyCode,
          localeCode: settings.localeCode,
        ),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  List<MonthProjection> _filterMonths(
    List<MonthProjection> months,
    ReportTimeRange range,
  ) {
    return switch (range) {
      ReportTimeRange.monthly => months.take(1).toList(growable: false),
      ReportTimeRange.yearly => months.take(12).toList(growable: false),
      ReportTimeRange.fullHistory => months,
    };
  }

  String _rangeLabel(AppLocalizations l10n, ReportTimeRange range) {
    return switch (range) {
      ReportTimeRange.monthly => l10n.reportsPreviewRangeMonthly,
      ReportTimeRange.yearly => l10n.reportsPreviewRangeYearly,
      ReportTimeRange.fullHistory => l10n.reportsPreviewRangeFullHistory,
    };
  }

  Future<pw.ThemeData> _loadTheme() async {
    final cachedTheme = _cachedTheme;
    if (cachedTheme != null) {
      return cachedTheme;
    }

    final regularFont = pw.Font.ttf(await rootBundle.load(_regularFontAsset));
    final boldFont = pw.Font.ttf(await rootBundle.load(_boldFontAsset));
    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: regularFont,
      boldItalic: boldFont,
    );
    _cachedTheme = theme;
    return theme;
  }
}
