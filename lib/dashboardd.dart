import 'package:flutter/material.dart';
import 'main.dart';
import 'studentdashboard/annoucements.dart';
import 'studentdashboard/conflictresolution.dart';
import 'studentdashboard/studentprofile.dart';
import 'studentdashboard/timeTable.dart';
import 'studentdashboard/appbar.dart';
import 'studentdashboard/getfailed.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './studentdashboard/studentResult.dart';

class Dashboard extends StatefulWidget {
  final String regno;
  Dashboard({super.key, required this.regno});
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 2;
  String status = 'no';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    final response = await http.get(
      Uri.parse('http://localhost/html/get_course_offering.php'),
    );

    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      setState(() {
        status = data['course_offering'];
        print(status); // for debugging
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Turn _screens into a getter so it uses updated `status`
  List<Widget> get _screens => [
        TimetableScreen(regno: widget.regno),
        GetFailedCoursesScreen(regno: widget.regno),
        AnnouncementsPage(
          regno: widget.regno,
        ),
        (status == "yes")
            ? ConflictResolutionScreen(regno: widget.regno)
            : StudentResultPage(regNo: widget.regno),
        StudentProfileScreen(regNo: widget.regno),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _signOut() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _screens[_selectedIndex],
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
                index: 0, icon: Icons.calendar_today, label: "Timetable"),
            _buildNavigationButton(
                index: 1, icon: Icons.assignment, label: "Results"),
            _buildNavigationButton(
                index: 2, icon: Icons.notifications, label: "Announcements"),
            _buildNavigationButton(
                index: 3, icon: Icons.school, label: "Proceeding"),
            _buildNavigationButton(
                index: 4, icon: Icons.person, label: "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
      {required int index, required IconData icon, required String label}) {
    return Container(
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
    );
  }
}
