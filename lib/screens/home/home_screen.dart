import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/debt_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/debt.dart';
import '../../widgets/debt_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/filter_chips.dart';
import 'debt_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              'Bista Utang',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: themeProvider.isDarkMode 
                ? const Color(0xFF1E1E1E) 
                : Colors.blue.shade600,
            elevation: 0,
            actions: [
              // Theme Toggle
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode 
                          ? Icons.light_mode 
                          : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    onPressed: () => themeProvider.toggleTheme(),
                  );
                },
              ),
              // Refresh Button
              Consumer<DebtProvider>(
                builder: (context, debtProvider, child) {
                  return IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => debtProvider.loadDebts(),
                  );
                },
              ),
            ],
          ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: themeProvider.isDarkMode 
                ? const Color(0xFF1E1E1E) 
                : Colors.blue.shade600,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<DebtProvider>().setSearchQuery(value);
                  },
                ),
                const SizedBox(height: 12),
                const FilterChips(),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Consumer<DebtProvider>(
              builder: (context, debtProvider, child) {
                if (debtProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (debtProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          debtProvider.error!,
                          style: GoogleFonts.inter(
                            color: themeProvider.isDarkMode 
                                ? Colors.red.shade400 
                                : Colors.red.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => debtProvider.loadDebts(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (debtProvider.filteredDebts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          debtProvider.searchQuery.isNotEmpty || debtProvider.statusFilter != null
                              ? 'No debts found matching your criteria'
                              : 'No debts yet',
                          style: GoogleFonts.inter(
                            color: themeProvider.isDarkMode 
                                ? Colors.grey.shade300 
                                : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          debtProvider.searchQuery.isNotEmpty || debtProvider.statusFilter != null
                              ? 'Try adjusting your search or filters'
                              : 'Tap the + button to add your first debt',
                          style: GoogleFonts.inter(
                            color: themeProvider.isDarkMode 
                                ? Colors.grey.shade400 
                                : Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => debtProvider.loadDebts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: debtProvider.filteredDebts.length,
                    itemBuilder: (context, index) {
                      final debt = debtProvider.filteredDebts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DebtCard(
                          debt: debt,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DebtDetailScreen(debt: debt),
                              ),
                            );
                          },
                          onStatusChanged: (newStatus) {
                            final updatedDebt = debt.copyWith(status: newStatus);
                            debtProvider.updateDebt(updatedDebt);
                          },
                          onDelete: () {
                            _showDeleteDialog(context, debt, debtProvider);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Debt debt, DebtProvider debtProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              title: Text(
                'Delete Debt',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to delete the debt for ${debt.debtorName}?',
                style: GoogleFonts.inter(
                  color: themeProvider.isDarkMode 
                      ? Colors.white 
                      : Colors.black87,
                ),
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
                debtProvider.deleteDebt(debt.id!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Debt deleted successfully',
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
              },
              child: Text(
                'Delete',
                style: GoogleFonts.inter(color: Colors.red.shade600),
              ),
            ),
          ],
            );
          },
        );
      },
    );
  }
}
