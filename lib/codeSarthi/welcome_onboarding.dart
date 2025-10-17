
import 'package:flutter/material.dart';
import 'package:cogni_sarthi/screens/welcome_screen.dart';

// This file is kept for backwards compatibility
// It now uses the updated WelcomeScreen from lib/screens/
class WelcomeOnboardingScreen extends StatelessWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WelcomeScreen();
  }
}
