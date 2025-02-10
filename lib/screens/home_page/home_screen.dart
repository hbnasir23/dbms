import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../widgets/bottom_navigation.dart';
import 'charts_screen.dart';
import 'profile_screen.dart';
import 'pharmacy_screen.dart';
import 'doctor_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const ChartsScreen();
      case 1:
        return const ProfileScreen();
      case 2:
        return _buildHomeScreen();
      case 3:
        return const DoctorScreen();
      case 4:
        return  UserPharmacyScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hi, User',
                  style: TextStyle(
                    fontSize: AppConstants.deviceWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
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
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
