import 'dart:async';
import 'package:aig/main.dart';
import 'package:aig/theme.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  final String userId;
  const LoadingPage({super.key, required this.userId});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();


    // Set a timer to navigate to the homepage after 5 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userId: widget.userId),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: AppC.lBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RotationTransition(
              turns: _controller,
              child: Icon(
                Icons.refresh,
                size: 50.0,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Loading to Home Page',
              style: AppText.text,
            ),
          ],
        ),
      ),
    );
  }
}