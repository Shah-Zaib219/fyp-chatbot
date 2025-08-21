import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(context), // Background Decoration
          _buildLoginContent(context), // Login Content (UI)
        ],
      ),
    );
  }

  /// Method to create background design
  Widget _buildBackground(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(color: Colors.white), // Base Background
        Positioned(
          top: -screenWidth * 0.15,
          left: -screenWidth * 0.15,
          child: Container(
            width: screenWidth * 0.4,
            height: screenWidth * 0.4,
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -screenWidth * 0.15,
          right: -screenWidth * 0.1,
          child: Container(
            width: screenWidth * 0.35,
            height: screenWidth * 0.4,
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  /// Method to create the login UI
  Widget _buildLoginContent(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/logo.png', // Replace with your image
              height: screenHeight * 0.2,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Welcome Back",
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildTextField(Icons.person, "Username", false),
            SizedBox(height: screenHeight * 0.02),
            _buildTextField(Icons.lock, "Password", true),
            SizedBox(height: screenHeight * 0.03),
            _buildLoginButton(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.02),
            _buildSignUpText(),
          ],
        ),
      ),
    );
  }

  /// Method to create text fields (Username & Password)
  Widget _buildTextField(IconData icon, String hint, bool isPassword) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Method to create the login button
  Widget _buildLoginButton(double screenWidth, double screenHeight) {
    return ElevatedButton(
      onPressed: () {
        _handleLogin();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.3,
        ),
      ),
      child: Text(
        "LOGIN",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  /// Method to create sign-up text
  Widget _buildSignUpText() {
    return GestureDetector(
      onTap: () {
        print("Navigate to Sign-up Page");
      },
      child: Text(
        "Don't have an account? Sign up",
        style: TextStyle(
          color: Colors.purple,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  /// Method to handle login functionality
  void _handleLogin() {
    print("Login Button Pressed!");
    // Add authentication logic here
  }
}
