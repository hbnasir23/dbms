import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dbms/constants.dart';
import 'package:dbms/screens/admin_dashboard/admin_dashboard.dart';
import 'package:dbms/screens/login_screen.dart';
import 'package:dbms/screens/signup_screen.dart';
import 'package:dbms/screens/user_screens/home_screen.dart';
import 'package:dbms/screens/splash_screen.dart';
import 'package:dbms/screens/user_screens/pharmacy/cart/cart_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dbms/screens/user_screens/purchase_history/purchase_history_provider.dart';
import 'package:dbms/screens/doctor_signup.dart';
import 'screens/doctors_dashboard/doctor_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ffoypyzwayogamvrzgkp.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmb3lweXp3YXlvZ2FtdnJ6Z2twIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk2MDM4NTgsImV4cCI6MjA1NTE3OTg1OH0.ODA9TCPdyphMp8jqZxlEOGwaT425WKnUrwgfldrBEnA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(
          create: (context) => PurchaseHistoryProvider(Supabase.instance.client),
        ), // Add PurchaseHistoryProvider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Health App',
        theme: ThemeData(
          primaryColor: AppColors.teal,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin_dashboard': (context) => const AdminDashboardScreen(),
          '/doctor_signup' : (context) =>  DoctorSignupScreen(),
          '/doctor_dashboard' : (context) =>  DoctorDashboardScreen(),
        },
      ),
    );
  }
}