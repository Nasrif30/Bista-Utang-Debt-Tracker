import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/debt_provider.dart';
import '../models/debt.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DebtProvider>(
      builder: (context, debtProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // All debts chip
              _buildFilterChip(
                context,
                'All',
                debtProvider.statusFilter == null,
                () => debtProvider.setStatusFilter(null),
              ),
              const SizedBox(width: 8),
              
              // Active debts chip
              _buildFilterChip(
                context,
                'Active',
                debtProvider.statusFilter == DebtStatus.active,
                () => debtProvider.setStatusFilter(DebtStatus.active),
              ),
              const SizedBox(width: 8),
              
              // Settled debts chip
              _buildFilterChip(
                context,
                'Settled',
                debtProvider.statusFilter == DebtStatus.settled,
                () => debtProvider.setStatusFilter(DebtStatus.settled),
              ),
              const SizedBox(width: 8),
              
              // Overdue debts chip
              _buildFilterChip(
                context,
                'Overdue',
                debtProvider.statusFilter == DebtStatus.overdue,
                () => debtProvider.setStatusFilter(DebtStatus.overdue),
              ),
              const SizedBox(width: 8),
              
              // Sort button
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sort,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sort',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                onSelected: (value) {
                  final parts = value.split('_');
                  final sortBy = parts[0];
                  final ascending = parts[1] == 'asc';
                  debtProvider.setSorting(sortBy, ascending);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'date_desc',
                    child: Row(
                      children: [
                        Icon(
                          debtProvider.sortBy == 'date' && !debtProvider.sortAscending
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text('Newest First', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date_asc',
                    child: Row(
                      children: [
                        Icon(
                          debtProvider.sortBy == 'date' && debtProvider.sortAscending
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text('Oldest First', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'amount_desc',
                    child: Row(
                      children: [
                        Icon(
                          debtProvider.sortBy == 'amount' && !debtProvider.sortAscending
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text('Highest Amount', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'amount_asc',
                    child: Row(
                      children: [
                        Icon(
                          debtProvider.sortBy == 'amount' && debtProvider.sortAscending
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text('Lowest Amount', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'name_asc',
                    child: Row(
                      children: [
                        Icon(
                          debtProvider.sortBy == 'name' && debtProvider.sortAscending
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text('Name A-Z', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'name_desc',
                    child: Row(
                      children: [
                        Icon(
                          debtProvider.sortBy == 'name' && !debtProvider.sortAscending
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text('Name Z-A', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
