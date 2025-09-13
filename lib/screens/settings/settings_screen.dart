import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              'Settings',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info Section
          _buildSectionCard(
            'App Information',
            [
              _buildListTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0',
                onTap: null,
              ),
              _buildListTile(
                icon: Icons.description_outlined,
                title: 'About',
                subtitle: 'Bista Utang - Debt Management App',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Data Management Section
          _buildSectionCard(
            'Data Management',
            [
              _buildListTile(
                icon: Icons.backup_outlined,
                title: 'Backup Data',
                subtitle: 'Export your debt data',
                onTap: () => _showBackupDialog(context),
              ),
              _buildListTile(
                icon: Icons.restore_outlined,
                title: 'Restore Data',
                subtitle: 'Import debt data from backup',
                onTap: () => _showRestoreDialog(context),
              ),
              _buildListTile(
                icon: Icons.delete_forever_outlined,
                title: 'Clear All Data',
                subtitle: 'Remove all debts (cannot be undone)',
                onTap: () => _showClearDataDialog(context),
                isDestructive: true,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // App Settings Section
          _buildSectionCard(
            'App Settings',
            [
              _buildListTile(
                icon: Icons.tour_outlined,
                title: 'Show Onboarding',
                subtitle: 'View the app introduction again',
                onTap: () => _showOnboarding(context),
              ),
              _buildListTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage reminder settings',
                onTap: () => _showNotificationSettings(context),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Support Section
          _buildSectionCard(
            'Support',
            [
              _buildListTile(
                icon: Icons.help_outline,
                title: 'Help & FAQ',
                subtitle: 'Get help using the app',
                onTap: () => _showHelpDialog(context),
              ),
              _buildListTile(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Report issues or suggest features',
                onTap: () => _showFeedbackDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode 
                        ? Colors.white 
                        : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                ...children,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: Icon(
            icon,
            color: isDestructive ? Colors.red.shade400 : Colors.blue.shade600,
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              color: isDestructive 
                  ? Colors.red.shade600 
                  : (themeProvider.isDarkMode ? Colors.white : Colors.grey.shade800),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.inter(
              color: themeProvider.isDarkMode 
                  ? Colors.grey.shade300 
                  : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          trailing: onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                )
              : null,
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Bista Utang',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        Text(
          'A modern Flutter app for monitoring debts with local storage and email notifications.',
          style: GoogleFonts.inter(),
        ),
      ],
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Backup Data',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This feature will be available in a future update. You can manually export your data from the Analytics screen.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(color: Colors.blue.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Restore Data',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This feature will be available in a future update.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(color: Colors.blue.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Clear All Data',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete all your debt data? This action cannot be undone.',
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
                // TODO: Implement clear all data
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Clear data feature coming soon!',
                      style: GoogleFonts.inter(),
                    ),
                  ),
                );
              },
              child: Text(
                'Clear',
                style: GoogleFonts.inter(color: Colors.red.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOnboarding(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Notification Settings',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Notification settings will be available in a future update.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(color: Colors.blue.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Help & FAQ',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How to add a debt:',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Tap the "Add Debt" tab\n2. Fill in the debtor information\n3. Enter the amount and currency\n4. Tap "Save Debt"',
                  style: GoogleFonts.inter(),
                ),
                const SizedBox(height: 16),
                Text(
                  'How to mark a debt as settled:',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Find the debt in the Home tab\n2. Tap "Mark Settled" on the debt card\n3. The debt status will update automatically',
                  style: GoogleFonts.inter(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: Colors.blue.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Send Feedback',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Thank you for using Bista Utang! Your feedback helps us improve the app.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: Colors.blue.shade600),
              ),
            ),
          ],
        );
      },
    );
  }
}
