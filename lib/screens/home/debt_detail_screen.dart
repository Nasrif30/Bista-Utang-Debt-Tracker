import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/debt_provider.dart';
import '../../models/debt.dart';
import '../add_debt/add_debt_screen.dart';

class DebtDetailScreen extends StatelessWidget {
  final Debt debt;

  const DebtDetailScreen({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Debt Details',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDebtScreen(debt: debt),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Debtor Information Card
            _buildInfoCard(
              'Debtor Information',
              Icons.person_outline,
              [
                _buildInfoRow('Name', debt.debtorName),
                if (debt.debtorEmail != null)
                  _buildInfoRow('Email', debt.debtorEmail!),
                if (debt.debtorPhone != null)
                  _buildInfoRow('Phone', debt.debtorPhone!),
                if (debt.facebookProfile != null)
                  _buildInfoRow('Facebook', debt.facebookProfile!),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Debt Details Card
            _buildInfoCard(
              'Debt Details',
              Icons.account_balance_wallet_outlined,
              [
                _buildInfoRow(
                  'Amount',
                  '${NumberFormat.currency(symbol: debt.currency == 'USD' ? '\$' : '₱').format(debt.amount)}',
                ),
                _buildInfoRow('Currency', debt.currency),
                _buildInfoRow('Status', debt.status.displayName),
                _buildInfoRow(
                  'Created',
                  DateFormat('MMM dd, yyyy').format(debt.createdAt),
                ),
                if (debt.dueDate != null)
                  _buildInfoRow(
                    'Due Date',
                    DateFormat('MMM dd, yyyy').format(debt.dueDate!),
                  ),
              ],
            ),
            
            if (debt.debtorNotes != null && debt.debtorNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                'Notes',
                Icons.note_outlined,
                [
                  Text(
                    debt.debtorNotes!,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendReminder(context),
                    icon: const Icon(Icons.email_outlined),
                    label: Text(
                      'Send Reminder',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleStatus(context),
                    icon: Icon(
                      debt.status == DebtStatus.active
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked,
                    ),
                    label: Text(
                      debt.status == DebtStatus.active
                          ? 'Mark Settled'
                          : 'Mark Active',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: debt.status == DebtStatus.active
                          ? Colors.green.shade600
                          : Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Facebook Profile Button
            if (debt.facebookProfile != null && debt.facebookProfile!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchFacebookProfile(debt.facebookProfile!),
                  icon: const Icon(Icons.facebook),
                  label: Text(
                    'Open Facebook Profile',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendReminder(BuildContext context) {
    if (debt.debtorEmail == null || debt.debtorEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No email address available for this debtor',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Send Reminder',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Send a reminder email to ${debt.debtorName} about the debt of ${NumberFormat.currency(symbol: debt.currency == 'USD' ? '\$' : '₱').format(debt.amount)}?',
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
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement email sending
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Reminder sent successfully!',
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
              },
              child: Text(
                'Send',
                style: GoogleFonts.inter(color: Colors.blue.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleStatus(BuildContext context) {
    final newStatus = debt.status == DebtStatus.active
        ? DebtStatus.settled
        : DebtStatus.active;
    
    final updatedDebt = debt.copyWith(status: newStatus);
    context.read<DebtProvider>().updateDebt(updatedDebt);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Debt status updated to ${newStatus.displayName}',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  Future<void> _launchFacebookProfile(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
