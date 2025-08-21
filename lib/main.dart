import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dashboardd.dart';
import 'adminlogin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? regNo = null;
  runApp(MyApp(regNo: regNo));
}

class MyApp extends StatelessWidget {
  final String? regNo;

  const MyApp({super.key, this.regNo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: regNo != null ? Dashboard(regno: "regNo") : LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController regNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedSession;
  String? selectedProgram;
  String runerror = "";
  List<String> sessions = [];
  List<Map<String, dynamic>> programs = [];
  bool isLoading = true;
  bool isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        _fetchPrograms(),
        _fetchBatches(),
      ]);
    } catch (e) {
      setState(() {
        runerror = "Failed to load initial data. Please try again.";
        isLoading = false;
      });
    }
  }

  Future<void> _fetchPrograms() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/html/fetch_program.php'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            programs = List<Map<String, dynamic>>.from(data['programs']);
            if (programs.isNotEmpty) {
              selectedProgram = programs.first['code'];
            }
          });
        }
      }
    } catch (e) {
      // Fallback default values
      setState(() {
        programs = [
          {'code': 'BSCS'},
          {'code': 'BSSE'}
        ];
        selectedProgram = programs.first['code'];
      });
    } finally {
      _checkLoadingComplete();
    }
  }

  Future<void> _fetchBatches() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/html/fetch_batches.php'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            sessions = List<String>.from(data['batches']);
            if (sessions.isNotEmpty) {
              selectedSession = sessions.first;
            }
          });
        }
      }
    } catch (e) {
      // Fallback default values
      setState(() {
        sessions = ['FA20', 'SP21', 'FA21'];
        selectedSession = sessions.first;
      });
    } finally {
      _checkLoadingComplete();
    }
  }

  void _checkLoadingComplete() {
    if (sessions.isNotEmpty && programs.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (selectedSession == null || selectedProgram == null) {
      setState(() {
        runerror = "Please select session and program";
      });
      return;
    }

    final regNumber = regNumberController.text.trim();
    if (regNumber.isEmpty) {
      setState(() {
        runerror = "Please enter registration number";
      });
      return;
    }

    final password = passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        runerror = "Please enter password";
      });
      return;
    }

    setState(() {
      isLoggingIn = true;
      runerror = "";
    });

    try {
      final username =
          "$selectedSession-$selectedProgram-$regNumber".toLowerCase();
      final url = Uri.parse('http://localhost/html/login.php');

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": username,
              "password": password,
            }),
          )
          .timeout(Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['status'] == "success") {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(
              regno: "$selectedSession-$selectedProgram-$regNumber",
            ),
          ),
        );
      } else {
        setState(() {
          runerror = data['message'] ?? "Login failed. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        runerror = "Network error. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoggingIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(screenSize),
          _buildLoginContent(screenSize),
        ],
      ),
    );
  }

  Widget _buildBackground(Size screenSize) {
    return Stack(
      children: [
        Container(color: Colors.white),
        Positioned(
          top: -screenSize.width * 0.15,
          left: -screenSize.width * 0.15,
          child: Container(
            width: screenSize.width * 0.4,
            height: screenSize.width * 0.4,
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -screenSize.width * 0.15,
          right: -screenSize.width * 0.1,
          child: Container(
            width: screenSize.width * 0.35,
            height: screenSize.width * 0.4,
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginContent(Size screenSize) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(screenSize),
              SizedBox(height: screenSize.height * 0.02),
              _buildUniversityTitle(screenSize),
              SizedBox(height: screenSize.height * 0.03),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    _buildLoginForm(),
                    SizedBox(height: screenSize.height * 0.02),
                    if (runerror.isNotEmpty)
                      Text(
                        runerror,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    SizedBox(height: screenSize.height * 0.01),
                    _buildLoginButton(screenSize),
                    SizedBox(height: screenSize.height * 0.02),
                    _buildSignUpText(),
                    SizedBox(height: 8),
                    _buildAdminLoginText(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue.shade800, width: 0.0),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/image/logo.png',
          height: screenSize.height * 0.2,
          width: screenSize.height * 0.2,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUniversityTitle(Size screenSize) {
    return Text(
      "Comsats University Islamabad, Dhamtour Campus",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: screenSize.width * 0.05,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade800,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSessionDropdown()),
            SizedBox(width: 8),
            Expanded(child: _buildProgramDropdown()),
            SizedBox(width: 8),
            Expanded(child: _buildRegistrationField()),
          ],
        ),
        SizedBox(height: 16),
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildSessionDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade800),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: selectedSession,
        items: sessions.map<DropdownMenuItem<String>>((String session) {
          return DropdownMenuItem<String>(
            value: session,
            child: Text(session),
          );
        }).toList(),
        onChanged: (String? value) => setState(() => selectedSession = value),
        decoration: InputDecoration(
          labelText: "Session",
          border: InputBorder.none,
        ),
        isExpanded: true,
      ),
    );
  }

  Widget _buildProgramDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade800),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: selectedProgram,
        items: programs
            .map<DropdownMenuItem<String>>((Map<String, dynamic> program) {
          return DropdownMenuItem<String>(
            value: program['code'],
            child: Text(program['code']),
          );
        }).toList(),
        onChanged: (String? value) => setState(() => selectedProgram = value),
        decoration: InputDecoration(
          labelText: "Program",
          border: InputBorder.none,
        ),
        isExpanded: true,
      ),
    );
  }

  Widget _buildRegistrationField() {
    return TextField(
      controller: regNumberController,
      decoration: InputDecoration(
        hintText: "Reg #",
        prefixIcon: Icon(Icons.numbers, color: Colors.blue.shade800),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade800),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Password",
        prefixIcon: Icon(Icons.lock, color: Colors.blue.shade800),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade800),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildLoginButton(Size screenSize) {
    return ElevatedButton(
      onPressed: isLoggingIn ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800,
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.width * 0.3,
        ),
      ),
      child: isLoggingIn
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              "LOGIN",
              style: TextStyle(color: Colors.white),
            ),
    );
  }

  Widget _buildSignUpText() {
    return GestureDetector(
      onTap: () async {
        const url = "https://sis.cuiatd.edu.pk/";
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Text(
        "Activate Mobile Application",
        style: TextStyle(
          color: Colors.blue.shade800,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildAdminLoginText() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminLoginScreen()),
        );
      },
      child: Text(
        "Admin Login",
        style: TextStyle(
          color: Colors.blue.shade800,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
