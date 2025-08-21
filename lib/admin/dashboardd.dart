import 'package:flutter/material.dart';
import '../main.dart';
import '../studentdashboard/annoucements.dart';
import 'annoucements.dart';
import 'package:http/http.dart';
import 'seeAnnouncements.dart';
import 'courseOfferingStstud.dart';
import 'uploadChatbotDocument.dart';

class adminDashboard extends StatefulWidget {
  final String username;
  adminDashboard({super.key, required this.username});
  @override
  _adminDashboardState createState() => _adminDashboardState();
}

class _adminDashboardState extends State<adminDashboard> {
  int _selectedIndex = 0; // Changed default to first tab

  // Screens for different options
  late final List<Widget> _screens = [
    UploadAnnouncementScreen(
      username: widget.username,
      adminId: 1, // from your login data
      departmentId: 9, // from your login data
    ),
    AdminAnnouncementsPage(),
    CourseOfferingTogglePage(),
    ChatbotPDFScreen(
      adminUsername: widget.username,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Handle Sign Out
  void _signOut() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blue[800],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavigationButton(
                index: 0, icon: Icons.add, label: "Add Announcement"),
            _buildNavigationButton(
                index: 1, icon: Icons.insert_drive_file, label: "Documents"),
            _buildNavigationButton(
                index: 2, icon: Icons.flag, label: "Course Offering"),
            _buildNavigationButton(
                index: 3, icon: Icons.add, label: "Add Document"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
      {required int index, required IconData icon, required String label}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _selectedIndex == index ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: _selectedIndex == index ? Colors.blue[800] : Colors.white,
            ),
            onPressed: () => _onItemTapped(index),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.white : Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
