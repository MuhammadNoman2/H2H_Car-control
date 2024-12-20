import 'package:flutter/material.dart';
import 'dart:async';

import 'home.dart'; // For using timers

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home screen after 800 milliseconds
    Timer(Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with your home screen widget
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Background color for splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Car logo in the center
            Image.asset(
              'assets/img.png', // Ensure you have a car logo in your assets folder
              width: 150,  // Adjust logo size
              height: 150,
            ),
            const SizedBox(height: 20),
            // Circular progress indicator with a beautiful style
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // White color for the spinner
              strokeWidth: 6.0, // Thickness of the circular progress
            ),
          ],
        ),
      ),
    );
  }
}
