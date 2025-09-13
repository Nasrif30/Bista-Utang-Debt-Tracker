import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:form_validator/form_validator.dart';
import 'package:uuid/uuid.dart';
import '../../providers/debt_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/debt.dart';
import '../../widgets/custom_text_field.dart';

class AddDebtScreen extends StatefulWidget {
  final Debt? debt; // For editing existing debt

  const AddDebtScreen({super.key, this.debt});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _debtorNameController = TextEditingController();
  final _debtorEmailController = TextEditingController();
  final _debtorPhoneController = TextEditingController();
  final _debtorNotesController = TextEditingController();
  final _facebookProfileController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedCurrency = 'USD';
  DateTime? _dueDate;
  DebtStatus _selectedStatus = DebtStatus.active;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final debt = widget.debt!;
    _debtorNameController.text = debt.debtorName;
    _debtorEmailController.text = debt.debtorEmail ?? '';
    _debtorPhoneController.text = debt.debtorPhone ?? '';
    _debtorNotesController.text = debt.debtorNotes ?? '';
    _facebookProfileController.text = debt.facebookProfile ?? '';
    _amountController.text = debt.amount.toString();
    _selectedCurrency = debt.currency;
    _dueDate = debt.dueDate;
    _selectedStatus = debt.status;
  }

  @override
  void dispose() {
    _debtorNameController.dispose();
    _debtorEmailController.dispose();
    _debtorPhoneController.dispose();
    _debtorNotesController.dispose();
    _facebookProfileController.dispose();
    _amountController.dispose();
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
              widget.debt != null ? 'Edit Debt' : 'Add New Debt',
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
              if (widget.debt != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: _showDeleteDialog,
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Debtor Information Card
                  _buildSectionCard(
                    'Debtor Information',
                    Icons.person_outline,
                    [
                      CustomTextField(
                        controller: _debtorNameController,
                        label: 'Full Name *',
                        hint: 'Enter debtor\'s full name',
                        validator: ValidationBuilder().required().build(),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _debtorEmailController,
                        label: 'Email Address',
                        hint: 'Enter email for notifications',
                        keyboardType: TextInputType.emailAddress,
                        validator: ValidationBuilder().email().build(),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _debtorPhoneController,
                        label: 'Phone Number',
                        hint: 'Enter phone number',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _facebookProfileController,
                        label: 'Facebook Profile Link',
                        hint: 'Paste Facebook profile URL',
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Debt Details Card
                  _buildSectionCard(
                    'Debt Details',
                    Icons.account_balance_wallet_outlined,
                    [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _amountController,
                              label: 'Amount *',
                              hint: '0.00',
                              keyboardType: TextInputType.number,
                              validator: ValidationBuilder()
                                  .required()
                                  .add((value) {
                                    final amount = double.tryParse(value!);
                                    if (amount == null || amount < 1) {
                                      return 'Amount must be at least 1';
                                    }
                                    return null;
                                  })
                                  .build(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Currency',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: themeProvider.isDarkMode 
                                        ? Colors.grey.shade300 
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedCurrency,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                                    DropdownMenuItem(value: 'PHP', child: Text('PHP')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCurrency = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Due Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Date (Optional)',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: themeProvider.isDarkMode 
                                  ? Colors.grey.shade300 
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectDueDate,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _dueDate != null
                                          ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                          : 'Select due date',
                                      style: GoogleFonts.inter(
                                        color: _dueDate != null
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: themeProvider.isDarkMode 
                                  ? Colors.grey.shade300 
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<DebtStatus>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: DebtStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Notes Card
                  _buildSectionCard(
                    'Additional Notes',
                    Icons.note_outlined,
                    [
                      CustomTextField(
                        controller: _debtorNotesController,
                        label: 'Notes',
                        hint: 'Add any additional notes about this debt...',
                        maxLines: 3,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveDebt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.debt != null ? 'Update Debt' : 'Save Debt',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode 
                              ? Colors.white 
                              : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...children,
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _saveDebt() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final debt = Debt(
        id: widget.debt?.id ?? const Uuid().v4(), // Generate ID for new debts
        debtorName: _debtorNameController.text.trim(),
        debtorEmail: _debtorEmailController.text.trim().isEmpty 
            ? null 
            : _debtorEmailController.text.trim(),
        debtorPhone: _debtorPhoneController.text.trim().isEmpty 
            ? null 
            : _debtorPhoneController.text.trim(),
        debtorNotes: _debtorNotesController.text.trim().isEmpty 
            ? null 
            : _debtorNotesController.text.trim(),
        facebookProfile: _facebookProfileController.text.trim().isEmpty 
            ? null 
            : _facebookProfileController.text.trim(),
        amount: double.parse(_amountController.text),
        currency: _selectedCurrency,
        createdAt: widget.debt?.createdAt ?? DateTime.now(),
        dueDate: _dueDate,
        status: _selectedStatus,
        userId: 'default_user', // Since we removed authentication
      );

      final debtProvider = context.read<DebtProvider>();
      
      if (widget.debt != null) {
        await debtProvider.updateDebt(debt);
      } else {
        await debtProvider.addDebt(debt);
      }

      if (mounted) {
        // Show success message first
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.debt != null 
                  ? 'Debt updated successfully!' 
                  : 'Debt added successfully!',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Debt',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this debt? This action cannot be undone.',
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
                await context.read<DebtProvider>().deleteDebt(widget.debt!.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Debt deleted successfully',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                }
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
  }
}
