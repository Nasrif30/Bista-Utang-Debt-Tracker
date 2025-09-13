import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/debt_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_navigation.dart';
import 'services/supabase_service.dart';
import 'services/simple_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseService.supabaseUrl,
    anonKey: SupabaseService.supabaseAnonKey,
  );
  
  // Initialize Simple Sync Service
  await SimpleSyncService.initialize();
  
  runApp(const BistaUtangApp());
}

class BistaUtangApp extends StatelessWidget {
  const BistaUtangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DebtProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Bista Utang',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme.copyWith(
              textTheme: GoogleFonts.interTextTheme(themeProvider.lightTheme.textTheme),
            ),
            darkTheme: themeProvider.darkTheme.copyWith(
              textTheme: GoogleFonts.interTextTheme(themeProvider.darkTheme.textTheme),
            ),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay
    
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
      
      if (hasCompletedOnboarding) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Bista Utang',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Debt Management Made Simple',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
