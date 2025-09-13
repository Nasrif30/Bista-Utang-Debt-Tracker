import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_navigation.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Track Your Debts",
          body: "Keep track of all money owed to you with detailed debtor information and flexible amounts.",
          image: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 100,
              color: Colors.blue.shade400,
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 40),
          ),
        ),
        PageViewModel(
          title: "Send Notifications",
          body: "Automatically notify debtors via email when debts are created or updated. Send reminders with a single tap.",
          image: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.email_outlined,
              size: 100,
              color: Colors.green.shade400,
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 40),
          ),
        ),
        PageViewModel(
          title: "Stay Organized",
          body: "View analytics, search debts, and export data. Keep everything organized with status tracking and due dates.",
          image: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 100,
              color: Colors.purple.shade400,
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 40),
          ),
        ),
        PageViewModel(
          title: "Ready to Start?",
          body: "Your debt tracking journey begins now. Add your first debt and start managing your finances better.",
          image: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.rocket_launch_outlined,
              size: 100,
              color: Colors.orange.shade400,
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 40),
          ),
        ),
      ],
      onDone: () => _onDone(context),
      onSkip: () => _onDone(context),
      showSkipButton: true,
      skip: Text(
        "Skip",
        style: GoogleFonts.inter(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
      next: Icon(
        Icons.arrow_forward,
        color: Colors.blue.shade600,
      ),
      done: Text(
        "Get Started",
        style: GoogleFonts.inter(
          color: Colors.blue.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.grey.shade300,
        activeSize: const Size(22.0, 10.0),
        activeColor: Colors.blue.shade600,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  void _onDone(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }
}
