import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // PALETTE
  final Color kLightLilac = const Color(0xFFF2E7FE);

  @override
  void initState() {
    super.initState();
    // 2-second timer before navigating to Home
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightLilac,
      body: Center(
        child: Image.asset(
          "assets/logo.png", // Ensure you have this asset
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}