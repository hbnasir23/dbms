import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../widgets/bottom_navigation.dart';
import 'charts_screen.dart';
import 'profile_screen.dart';
import 'pharmacy/user_pharmacy_screen.dart';
import 'doctor_screen.dart';
import 'package:dbms/globals.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 2;

  Widget getCurrentScreen() {
    switch (selectedIndex) {
      case 0:
        return const ChartsScreen();
      case 1:
        return const ProfileScreen();
      case 2:
        return buildHomeScreen();
      case 3:
        return const DoctorScreen();
      case 4:
        return const UserPharmacyScreen();
      default:
        return buildHomeScreen();
    }
  }
  void showSettingsDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Settings",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.white,
            child: SizedBox(
              width: AppConstants.deviceWidth * 0.6,
              height: AppConstants.deviceHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height:
                      AppConstants.deviceHeight * .10), // Space from top
                  ListTile(
                    leading: const Icon(Icons.info, color: AppColors.teal),
                    title: const Text("About"),
                    onTap: () {
                      Navigator.pop(context);
                      showAboutPopup();
                    },
                  ),
                  // Add Purchase History Button
                  ListTile(
                    leading: const Icon(Icons.history, color: AppColors.teal),
                    title: const Text("Purchase History"),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      // Navigate to the Purchase History Screen
                      Navigator.pushNamed(context, '/purchase-history'); // Navigate to Purchase History Screen

                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Logout"),
                    onTap: () {
                      AuthService().clearCredentials();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0), // Start off-screen left
            end: Offset.zero, // Slide into place
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  void showAboutPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("About This App"),
          content: const Text(
            "This is a health tracking application that helps users monitor their medical records and connect with doctors.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget buildHomeScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: AppColors.teal),
                      onPressed: showSettingsDrawer,
                    ),
                    Text(
                      'Hi, $loggedInUsername!',
                      style: TextStyle(
                        fontSize: AppConstants.deviceWidth * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/images/logo.png',
                  height: AppConstants.deviceHeight * 0.08,
                ),
              ],
            ),
            SizedBox(height: AppConstants.deviceHeight * 0.05),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppConstants.deviceHeight * 0.02,
                crossAxisSpacing: AppConstants.deviceWidth * 0.04,
                children: List.generate(5, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'Tile ${index + 1}',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: AppConstants.deviceWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
