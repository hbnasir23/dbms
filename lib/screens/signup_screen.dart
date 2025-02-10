import 'package:flutter/material.dart';
import 'package:dbms/database/login_db_helper.dart';
import 'package:dbms/constants.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _handleSignup(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    try {
      // Check if email exists
      bool emailExists = await _dbHelper.checkEmailExists(emailController.text);

      if (emailExists) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Email already exists')));
        return;
      }

      // Insert new user
      await _dbHelper.insertUser(
          emailController.text,
          passwordController.text
      );

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully'))
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false, // Ensures the header touches the top
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // Dismiss keyboard on scroll
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.deviceWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Container
                      Container(
                        width: AppConstants.deviceWidth,
                        height: AppConstants.deviceHeight * 0.25,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
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

                      SizedBox(height: AppConstants.deviceHeight * 0.038),

                      // Centered Title
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.teal,
                          ),
                        ),
                      ),

                      SizedBox(height: AppConstants.deviceHeight * 0.038),

                      // Email Input
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: Color(0xFFF8F9FE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),

                      SizedBox(height: AppConstants.deviceHeight * 0.019),

                      // Password Input
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Color(0xFFF8F9FE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),

                      SizedBox(height: AppConstants.deviceHeight * 0.019),

                      // Confirm Password Input
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          filled: true,
                          fillColor: Color(0xFFF8F9FE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),

                      SizedBox(height: AppConstants.deviceHeight * 0.038),

                      // Signup Button (Full Width)
                      SizedBox(
                        width: AppConstants.deviceWidth, // Full width
                        child: ElevatedButton(
                          onPressed: () => _handleSignup(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppConstants.deviceHeight * 0.028),

                      // Already have an account? Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          'Already have an account',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      // Push content above keyboard
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
