import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dbms/constants.dart';
import 'package:dbms/screens/admin_dashboard/admin_dashboard.dart';
import 'package:dbms/screens/login_screen.dart';
import 'package:dbms/screens/signup_screen.dart';
import 'package:dbms/screens/home_page/home_screen.dart';
import 'package:dbms/screens/splash_screen.dart';
import 'package:dbms/cart/cart_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Health App',
        theme: ThemeData(
          primaryColor: AppColors.teal,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => HomeScreen(),
          '/admin_dashboard': (context) => AdminDashboardScreen(),
        },
      ),
    );
  }
}