import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESCANNER',
      home: AnimatedSplashScreen(
        splash: Image.asset(
            'assets/scanner.gif'), // Replace 'your_logo.gif' with your animated logo file
        nextScreen:
            HomeScreen(), // Replace HomeScreen() with the main screen of your app
        splashTransition: SplashTransition.fadeTransition,
        duration:
            3000, // Duration in milliseconds for how long the splash screen should be shown
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Ticket Scanner'),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Welcome to Flutter Home Page!'),
      ),
    );
  }
}
