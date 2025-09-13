import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import '../models/debt.dart';

class ExportService {
  static Future<void> exportToCSV(List<Debt> debts) async {
    try {
      // Create CSV data
      List<List<dynamic>> csvData = [
        [
          'Debtor Name',
          'Email',
          'Phone',
          'Amount',
          'Currency',
          'Status',
          'Created Date',
          'Due Date',
          'Notes',
          'Facebook Profile'
        ]
      ];

      for (final debt in debts) {
        // Format amount with proper currency symbol
        String formattedAmount = _formatCurrency(debt.amount, debt.currency);
        
        csvData.add([
          debt.debtorName,
          debt.debtorEmail ?? '',
          debt.debtorPhone ?? '',
          formattedAmount,
          debt.currency,
          debt.status.displayName,
          DateFormat('yyyy-MM-dd').format(debt.createdAt),
          debt.dueDate != null ? DateFormat('yyyy-MM-dd').format(debt.dueDate!) : '',
          debt.debtorNotes ?? '',
          debt.facebookProfile ?? '',
        ]);
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      if (kIsWeb) {
        // For web, download directly
        final bytes = utf8.encode(csvString);
        final blob = html.Blob([bytes], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'debts_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile, save to file and share
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'debts_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
        final file = File('${directory.path}/$fileName');

        // Write to file
        await file.writeAsString(csvString);

        // Share the file
        await Share.shareXFiles([XFile(file.path)], text: 'Debt Export - CSV');
      }
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  static Future<void> exportToPDF(List<Debt> debts) async {
    try {
      final pdf = pw.Document();

      // Calculate totals by currency
      Map<String, double> totalAmountsByCurrency = {};
      Map<String, double> activeAmountsByCurrency = {};
      Map<String, double> settledAmountsByCurrency = {};
      
      for (final debt in debts) {
        final currency = debt.currency;
        totalAmountsByCurrency[currency] = (totalAmountsByCurrency[currency] ?? 0) + debt.amount;
        
        if (debt.status == DebtStatus.active) {
          activeAmountsByCurrency[currency] = (activeAmountsByCurrency[currency] ?? 0) + debt.amount;
        } else if (debt.status == DebtStatus.settled) {
          settledAmountsByCurrency[currency] = (settledAmountsByCurrency[currency] ?? 0) + debt.amount;
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Debt Management Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Summary',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Total Debts: ${debts.length}'),
                    pw.SizedBox(height: 10),
                    // Show totals by currency
                    ...totalAmountsByCurrency.entries.map((entry) {
                      final currency = entry.key;
                      final total = entry.value;
                      final active = activeAmountsByCurrency[currency] ?? 0.0;
                      final settled = settledAmountsByCurrency[currency] ?? 0.0;
                      
                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '${currency} Summary:',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total: ${_formatCurrency(total, currency)}'),
                              pw.Text('Active: ${_formatCurrency(active, currency)}'),
                              pw.Text('Settled: ${_formatCurrency(settled, currency)}'),
                            ],
                          ),
                          pw.SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Debts table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Debtor Name',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Amount',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Status',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Created',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Due Date',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Data rows
                  ...debts.map((debt) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(debt.debtorName),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(_formatCurrency(debt.amount, debt.currency)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(debt.status.displayName),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(DateFormat('MMM dd, yyyy').format(debt.createdAt)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          debt.dueDate != null 
                              ? DateFormat('MMM dd, yyyy').format(debt.dueDate!)
                              : 'N/A'
                        ),
                      ),
                    ],
                  )).toList(),
                ],
              ),
              pw.SizedBox(height: 20),

              // Footer
              pw.Text(
                'Generated on ${DateFormat('MMMM dd, yyyy at HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ];
          },
        ),
      );

      if (kIsWeb) {
        // For web, download directly
        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'debts_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile, save to file and share
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'debts_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(await pdf.save());

        // Share the file
        await Share.shareXFiles([XFile(file.path)], text: 'Debt Export - PDF');
      }
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  // Helper method to format currency (PDF-safe version)
  static String _formatCurrency(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'PHP':
        return 'PHP ${amount.toStringAsFixed(2)}'; // Use PHP instead of ₱ for PDF compatibility
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return 'EUR ${amount.toStringAsFixed(2)}'; // Use EUR instead of € for PDF compatibility
      case 'GBP':
        return 'GBP ${amount.toStringAsFixed(2)}'; // Use GBP instead of £ for PDF compatibility
      case 'JPY':
        return 'JPY ${amount.toStringAsFixed(0)}'; // Use JPY instead of ¥ for PDF compatibility
      default:
        return '${currency} ${amount.toStringAsFixed(2)}';
    }
  }
}
