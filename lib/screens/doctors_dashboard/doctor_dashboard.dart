import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../services/auth_service.dart';


class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  DoctorDashboardScreenState createState() => DoctorDashboardScreenState();
}

class DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int selectedIndex = 1; // Default to Schedule

  Widget getCurrentScreen() {
    switch (selectedIndex) {
      case 0:
        return const DoctorProfileScreen();
      case 1:
        return const DoctorScheduleScreen();
      case 2:
        return const DoctorAppointmentsScreen();
      default:
        return const DoctorScheduleScreen();
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
                  SizedBox(height: AppConstants.deviceHeight * .10), // Space from top
                  ListTile(
                    leading: const Icon(Icons.info, color: AppColors.teal),
                    title: const Text("About"),
                    onTap: () {
                      Navigator.pop(context);
                      showAboutPopup();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history, color: AppColors.teal),
                    title: const Text("Purchase History"),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      // Navigate to the Purchase History Screen
                      Navigator.pushNamed(context, '/purchase-history');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Logout"),
                    onTap: () {
                      // Clear credentials and navigate to login screen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: AppColors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: showSettingsDrawer,
          ),
        ],
      ),
      body: getCurrentScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.teal,
          unselectedItemColor: Colors.grey,
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Container(
                decoration: const BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(AppConstants.deviceWidth * 0.03),
                child: const Icon(Icons.calendar_today, color: Colors.white),
              ),
              label: 'Schedule',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Appointments',
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens for Profile, Schedule, and Appointments
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Doctor Profile Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class DoctorScheduleScreen extends StatelessWidget {
  const DoctorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Doctor Schedule Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Doctor Appointments Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}