
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('[Main] ✅ Environment variables loaded successfully');
    print('[Main] 🔍 Checking GEMINI_API_KEY: ${dotenv.env['GEMINI_API_KEY']?.isEmpty ?? true ? "NOT FOUND" : "Found"}');
    print('[Main] 🔍 Available env keys: ${dotenv.env.keys.toList()}');
  } catch (e) {
    print('[Main] ⚠️ Warning: Could not load .env file: $e');
    print('[Main] Using default configuration');
  }
  
  runApp(const CogniSarthiApp());
}

class CogniSarthiApp extends StatelessWidget {
  const CogniSarthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CogniSarthi - Mining Operations Co-Pilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4F46E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
        ),
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
