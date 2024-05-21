import 'dart:async';

import 'package:aig/API/database.dart';
import 'package:aig/pages/loading.dart';
import 'package:aig/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Database db = Database();

  bool isLogin = true;

  // Variables to keep track of empty text fields
  bool _usernameError = false;
  bool _passwordError = false;
  bool _messageError = false;
  String? _message;

  // Loading
  bool isLoading = false;

  // Timer to clear message
  Timer? _messageClearTimer;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _messageClearTimer?.cancel();
    super.dispose();
  }

  // Method to validate input fields
  bool validateInputs() {
    setState(() {
      _usernameError = (_usernameController.text.isEmpty);
      _passwordError = (_passwordController.text.isEmpty);
    });
    return !_usernameError && !_passwordError;
  }

  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
      _usernameError = false;
      _passwordError = false;
    });
  }

  void _submit() async {
    if (!validateInputs()) return;

    setState(() {
      isLoading = true;
    });

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    try {
      if (isLogin) {
        String profileId = await db.loginUser(username, password);
        if (mounted) {
          if (profileId.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoadingPage(userId: profileId),
              ),
            );
          } else {
            setState(() {
              _messageError = true;
              _message = "Login failed";
              isLoading = false;
            });
          }
        }
      } else {
        bool check = await db.registerUser(username, password);
        if (mounted) {
          setState(() {
            if (check) {
              isLogin = !isLogin;
              _messageError = false;
              _message = 'Registration successful';
            } else {
              _messageError = true;
              _message = 'Registration failed';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messageError = true;
          _message = 'An error occurred';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _messageClearTimer = Timer(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _message = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // padding
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingWidth = screenWidth * 0.1;
    double paddingHeight = screenHeight * 0.15;

    return Scaffold(
      backgroundColor: AppC.bgdWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: paddingHeight),
                  if (_message != null && !_messageError) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        color: AppC.lGrey,
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppC.green2,
                              size: 30.0,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _message!,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: AppC.green2,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ] else if (_message != null && _messageError) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        color: AppC.lGrey,
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: AppC.red,
                              size: 30.0,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _message!,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: AppC.red,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                    child: Column(
                      children: [
                        Text(
                          isLogin ? 'Sign in to Your Account' : 'Sign Up for Free',
                          style: AppText.title,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            counterText: '',
                            errorText: _usernameError ? 'Username cannot be empty' : null,
                          ),
                          maxLength: 30,
                          inputFormatters: [LengthLimitingTextInputFormatter(30)],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            counterText: '',
                            errorText: _passwordError ? 'Password cannot be empty' : null,
                          ),
                          obscureText: true,
                          maxLength: 30,
                          inputFormatters: [LengthLimitingTextInputFormatter(30)],
                        ),
                        SizedBox(height: 50),
                        OutlinedButton(
                          onPressed: _submit,
                          style: AppButton.buttonStyleAuth,
                          child: Text(
                            isLogin ? 'Login' : 'Register',
                            style: AppText.button,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: _toggleForm,
                          child: Text(
                            isLogin
                                ? 'Don\'t have an account? Register'
                                : 'Already have an account? Login',
                            style: AppText.text3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
