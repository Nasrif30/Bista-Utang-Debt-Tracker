import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/debt_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/debt.dart';
import '../../services/export_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode 
              ? const Color(0xFF121212) 
              : Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              'Analytics',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: themeProvider.isDarkMode 
                ? const Color(0xFF1E1E1E) 
                : Colors.blue.shade600,
            elevation: 0,
          ),
          body: Consumer<DebtProvider>(
            builder: (context, debtProvider, child) {
              if (debtProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final activeDebts = debtProvider.getActiveDebts();
              final settledDebts = debtProvider.getSettledDebts();
              final overdueDebts = debtProvider.getOverdueDebts();
              
              final totalAmount = debtProvider.getTotalAmount();
              final activeAmount = debtProvider.getActiveAmount();
              final settledAmount = debtProvider.getSettledAmount();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummaryCard(
                      'Total Debts',
                      debtProvider.debts.length.toString(),
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSummaryCard(
                      'Total Amount',
                      NumberFormat.currency(symbol: '\$').format(totalAmount),
                      Icons.attach_money,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSummaryCard(
                      'Active Amount',
                      NumberFormat.currency(symbol: '\$').format(activeAmount),
                      Icons.trending_up,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSummaryCard(
                      'Settled Amount',
                      NumberFormat.currency(symbol: '\$').format(settledAmount),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Status Breakdown
                    Text(
                      'Status Breakdown',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode 
                            ? Colors.white 
                            : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                            'Active',
                            activeDebts.length.toString(),
                            activeAmount,
                            Colors.red,
                            Icons.schedule,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusCard(
                            'Settled',
                            settledDebts.length.toString(),
                            settledAmount,
                            Colors.green,
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                    
                    if (overdueDebts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildStatusCard(
                        'Overdue',
                        overdueDebts.length.toString(),
                        overdueDebts.fold(0.0, (sum, debt) => sum + debt.amount),
                        Colors.orange,
                        Icons.warning,
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Recent Debts
                    Text(
                      'Recent Debts',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode 
                            ? Colors.white 
                            : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (debtProvider.debts.isEmpty)
                      _buildEmptyState()
                    else
                      ...debtProvider.debts.take(5).map((debt) => 
                        _buildRecentDebtItem(debt)
                      ).toList(),
                    
                    const SizedBox(height: 24),
                    
                    // Export Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _showExportDialog(context, debtProvider),
                        icon: const Icon(Icons.download),
                        label: Text(
                          'Export Data',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String status,
    String count,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(symbol: '\$').format(amount),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDebtItem(Debt debt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(debt.status).withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: _getStatusColor(debt.status),
          ),
        ),
        title: Text(
          debt.debtorName,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${NumberFormat.currency(symbol: '\$').format(debt.amount)} • ${debt.status.displayName}',
          style: GoogleFonts.inter(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Text(
          DateFormat('MMM dd').format(debt.createdAt),
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No debts yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first debt to see analytics',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DebtStatus status) {
    switch (status) {
      case DebtStatus.active:
        return Colors.red;
      case DebtStatus.settled:
        return Colors.green;
      case DebtStatus.overdue:
        return Colors.orange;
    }
  }

  void _showExportDialog(BuildContext context, DebtProvider debtProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Export Data',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Choose the format to export your debt data:',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ExportService.exportToCSV(debtProvider.debts);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'CSV exported successfully!',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to export CSV: $e',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: Colors.red.shade600,
                    ),
                  );
                }
              },
              child: Text(
                'CSV',
                style: GoogleFonts.inter(color: Colors.blue.shade600),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ExportService.exportToPDF(debtProvider.debts);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'PDF exported successfully!',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to export PDF: $e',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: Colors.red.shade600,
                    ),
                  );
                }
              },
              child: Text(
                'PDF',
                style: GoogleFonts.inter(color: Colors.blue.shade600),
              ),
            ),
          ],
        );
      },
    );
  }
}
