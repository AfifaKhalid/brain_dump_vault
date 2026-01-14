import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/hive_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.init();
  
  // Set preferred orientations (optional - allows both portrait and landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BrainDumpVaultApp());
}

class BrainDumpVaultApp extends StatelessWidget {
  const BrainDumpVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cozy color palette - used consistently throughout
    const primaryColor = Color(0xFF4b3832); // Dark brown
    const secondaryColor = Color(0xFF854442); // Warm red-brown
    const backgroundColor = Color(0xFFfff4e6); // Cream/beige
    const darkAccentColor = Color(0xFF3c2f2f); // Darker brown
    const highlightColor = Color(0xFFbe9b7b); // Soft tan

    return MaterialApp(
      title: 'Brain Dump Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: backgroundColor,
          error: const Color(0xFFB00020),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: darkAccentColor,
          onError: Colors.white,
          surfaceContainerHighest: highlightColor.withValues(alpha: 0.3),
          surfaceContainer: highlightColor.withValues(alpha: 0.2),
          surfaceContainerLow: highlightColor.withValues(alpha: 0.1),
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: darkAccentColor.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: secondaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: backgroundColor,
          foregroundColor: darkAccentColor,
          titleTextStyle: TextStyle(
            color: darkAccentColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: primaryColor),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            height: 1.2,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.3,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.4,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
