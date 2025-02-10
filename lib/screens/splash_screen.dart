import 'package:flutter/material.dart';
import 'package:dbms/constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {

    super.initState();


    // Animation Controller for smooth transitions
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define the logo and text animation
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start the animation
    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    AppConstants.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated logo
            FadeTransition(
              opacity: _logoAnimation,
              child: Container(
                height: AppConstants.deviceHeight * 0.3,
                width: AppConstants.deviceWidth ,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppConstants.deviceHeight * 0.05),
            // Animated app name text
            FadeTransition(
              opacity: _textAnimation,
              child: Text(
                'Health App',
                style: TextStyle(
                  fontSize: AppConstants.deviceWidth * 0.08,
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: AppConstants.deviceHeight * 0.01),
            // Tagline text
            FadeTransition(
              opacity: _textAnimation,
              child: Text(
                'Take care of your health',
                style: TextStyle(
                  fontSize: AppConstants.deviceWidth * 0.05,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
