import 'package:flutter/material.dart';
import 'package:dbms/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypt/crypt.dart';
import 'package:dbms/globals.dart';
import '../services/auth_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _stayLoggedIn = false;
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await _authService.getSavedCredentials();
    if (credentials['email'] != null && credentials['password'] != null) {
      setState(() {
        emailController.text = credentials['email']!;
        passwordController.text = credentials['password']!;
        _stayLoggedIn = credentials['stayLoggedIn'] == 'true';
      });
    }
  }
  Future<int?> getUserIdByEmail(String email) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('users')
        .select('id')
        .eq('email', email)
        .single();

    if (response != null) {
      return response['id'];
    } else {
      return null;
    }
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });
    try {
      PostgrestList response = await Supabase.instance.client
          .from('users')
          .select("email")
          .eq("email", emailController.text);

      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No Such Account Exists')));
        return;
      }
      var res = await Supabase.instance.client
          .from('users')
          .select()
          .eq('email', emailController.text);


      if (res[0]['role'] == 'admin' &&
          res[0]['password'] == passwordController.text) {
        // Save credentials with admin role
        await _authService.saveCredentials(
            emailController.text,
            passwordController.text,
            _stayLoggedIn,
            'admin'  // Save the role
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login Successful')));
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else if (Crypt(res[0]['password']).match(passwordController.text) &&
          res[0]['role'] == 'user') {
        String name = res[0]['name'];
        loggedInUsername = name.split(' ')[0];
        loggedInEmail = res[0]['email'];

        // Save credentials with user role
        await _authService.saveCredentials(
            emailController.text,
            passwordController.text,
            _stayLoggedIn,
            'user'  // Save the role
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login Successful')));
        Navigator.pushReplacementNamed(context, '/home');
      }else if (Crypt(res[0]['password']).match(passwordController.text) &&
          res[0]['role'] == 'doctor') {
        String name = res[0]['name'];
        loggedInUsername = name.split(' ')[0];
        loggedInEmail = res[0]['email'];

        // Save credentials with doctor role
        await _authService.saveCredentials(
            emailController.text,
            passwordController.text,
            _stayLoggedIn,
            'doctor'  // Save the role
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login Successful')));
        Navigator.pushReplacementNamed(context, '/doctor_dashboard');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Invalid Credentials')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.deviceWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: AppConstants.deviceWidth * 0.91,
                        height: AppConstants.deviceHeight * 0.25,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16)),
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
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.teal),
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
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: AppConstants.deviceHeight * 0.01),
                      // Add Stay Logged In checkbox
                      CheckboxListTile(
                        title: const Text('Stay Logged In'),
                        value: _stayLoggedIn,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: AppColors.teal,
                        onChanged: (value) {
                          setState(() {
                            _stayLoggedIn = value ?? false;
                          });
                        },
                      ),
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
                      SizedBox(
                        width: AppConstants.deviceWidth * 0.9,
                        child: ElevatedButton(
                          onPressed:
                          _isLoading ? null : () => _handleLogin(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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
                      SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom),
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