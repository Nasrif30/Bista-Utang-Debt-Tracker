import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/theme_provider.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback? onTap;
  final Function(DebtStatus)? onStatusChanged;
  final VoidCallback? onDelete;

  const DebtCard({
    super.key,
    required this.debt,
    this.onTap,
    this.onStatusChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          elevation: 6,
          shadowColor: _getAmountColor().withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeProvider.isDarkMode 
                        ? const Color(0xFF1E293B) 
                        : Colors.white,
                    _getAmountColor().withOpacity(0.05),
                  ],
                ),
              ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      debt.debtorName,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode 
                            ? Colors.white 
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Amount
              Text(
                '${NumberFormat.currency(symbol: debt.currency == 'USD' ? '\$' : '₱').format(debt.amount)}',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getAmountColor(),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Debtor info
              if (debt.debtorEmail != null) ...[
                _buildInfoRow(Icons.email_outlined, debt.debtorEmail!),
                const SizedBox(height: 4),
              ],
              if (debt.debtorPhone != null) ...[
                _buildInfoRow(Icons.phone_outlined, debt.debtorPhone!),
                const SizedBox(height: 4),
              ],
              if (debt.dueDate != null) ...[
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Due: ${DateFormat('MMM dd, yyyy').format(debt.dueDate!)}',
                ),
                const SizedBox(height: 4),
              ],
              _buildInfoRow(
                Icons.access_time_outlined,
                'Created: ${DateFormat('MMM dd, yyyy').format(debt.createdAt)}',
              ),
              
              if (debt.debtorNotes != null && debt.debtorNotes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  debt.debtorNotes!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: themeProvider.isDarkMode 
                        ? Colors.grey.shade300 
                        : Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  if (debt.facebookProfile != null && debt.facebookProfile!.isNotEmpty)
                    IconButton(
                      onPressed: () => _launchFacebookProfile(debt.facebookProfile!),
                      icon: Icon(
                        Icons.facebook,
                        color: Colors.blue.shade600,
                      ),
                      tooltip: 'Open Facebook Profile',
                    ),
                  
                  const Spacer(),
                  
                  // Status toggle button
                  if (onStatusChanged != null)
                    TextButton.icon(
                      onPressed: () {
                        final newStatus = debt.status == DebtStatus.active
                            ? DebtStatus.settled
                            : DebtStatus.active;
                        onStatusChanged!(newStatus);
                      },
                      icon: Icon(
                        debt.status == DebtStatus.active
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked,
                        size: 18,
                      ),
                      label: Text(
                        debt.status == DebtStatus.active ? 'Mark Settled' : 'Mark Active',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: debt.status == DebtStatus.active
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                      ),
                    ),
                  
                  // Delete button
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                      ),
                      tooltip: 'Delete Debt',
                    ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    
    switch (debt.status) {
      case DebtStatus.active:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case DebtStatus.settled:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case DebtStatus.overdue:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        debt.status.displayName,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: themeProvider.isDarkMode 
                  ? Colors.grey.shade400 
                  : Colors.grey.shade500,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: themeProvider.isDarkMode 
                      ? Colors.grey.shade300 
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getAmountColor() {
    switch (debt.status) {
      case DebtStatus.active:
        return Colors.red.shade600;
      case DebtStatus.settled:
        return Colors.green.shade600;
      case DebtStatus.overdue:
        return Colors.orange.shade600;
    }
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
