import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import './admin/dashboardd.dart'; // Replace with your actual dashboard
import 'main.dart'; // This takes user back to student login

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String runerror = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(context),
          _buildLoginContent(context),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(color: Colors.white),
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

  Widget _buildLoginContent(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade800, width: 0.0),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/image/logo.png',
                  height: screenHeight * 0.2,
                  width: screenHeight * 0.2,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Admin Panel - Comsats University",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildTextField(
              Icons.email,
              "Email",
              emailController,
              false,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildTextField(
              Icons.lock,
              "Password",
              passwordController,
              true,
            ),
            Text(
              runerror,
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
            SizedBox(height: screenHeight * 0.01),
            _buildLoginButton(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.02),
            _buildBackToStudentLoginText(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint,
      TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade800),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade800),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildLoginButton(double screenWidth, double screenHeight) {
    return ElevatedButton(
      onPressed: _handleAdminLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800,
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

  Widget _buildBackToStudentLoginText() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      },
      child: Text(
        "Back to Student Login",
        style: TextStyle(
          color: Colors.blue.shade800,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _handleAdminLogin() async {
    String username = emailController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => runerror = "Please enter username and password");
      return;
    }

    const url = "http://localhost/html/adminlogin.php";

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": username,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      // First check if response is valid JSON
      final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

      // Then check the status field exists
      if (!decodedResponse.containsKey('status')) {
        setState(() => runerror = "Invalid server response format");
        return;
      }

      if (decodedResponse["status"] == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => adminDashboard(username: username),
          ),
        );
      } else {
        setState(() => runerror = decodedResponse["message"] ?? "Login failed");
      }
    } on FormatException {
      setState(() => runerror = "Invalid server response (bad format)");
    } catch (e) {
      print("Login error: $e");
      if (e.toString().contains('TimeoutException')) {
        setState(() => runerror = "Connection timeout");
      } else if (e.toString().contains('SocketException')) {
        setState(() => runerror = "Network unavailable");
      } else {
        setState(() => runerror = "Login failed. Please try again.");
      }
    }
  }
}
