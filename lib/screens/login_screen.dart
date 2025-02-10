import 'package:flutter/material.dart';
import 'package:dbms/database/login_db_helper.dart';
import 'package:dbms/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isPasswordVisible = false;
  bool _isAdminChecked = false;

  Future<void> _handleLogin(BuildContext context) async {
    try {
      if (_isAdminChecked) {
        if (emailController.text == 'admin@gmail.com' && passwordController.text == '123') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Admin Credentials')),
          );
          return;
        }
      }

      var user = await _dbHelper.getUserByCredentials(
        emailController.text,
        passwordController.text,
      );

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.deviceWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: AppConstants.deviceWidth * 0.91,
                        height: AppConstants.deviceHeight * 0.25,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: AppConstants.deviceWidth * 0.4,
                            height: AppConstants.deviceHeight * 0.15,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: AppConstants.deviceHeight * 0.04),
                      const Text(
                        'Login',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.teal),
                      ),
                      SizedBox(height: AppConstants.deviceHeight * 0.04),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: AppConstants.deviceHeight * 0.02),
                      TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: AppConstants.deviceHeight * 0.02),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot your password?',
                            style: TextStyle(color: AppColors.teal),
                          ),
                        ),
                      ),
                      SizedBox(height: AppConstants.deviceHeight * 0.02),
                      Row(
                        children: [
                          Checkbox(
                            value: _isAdminChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isAdminChecked = value ?? false;
                              });
                            },
                          ),
                          const Text('Login as Admin'),
                        ],
                      ),
                      SizedBox(height: AppConstants.deviceHeight * 0.02),
                      SizedBox(
                        width: AppConstants.deviceWidth * 0.9,
                        child: ElevatedButton(
                          onPressed: () => _handleLogin(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: AppConstants.deviceHeight * 0.03),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          'Create new account',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
