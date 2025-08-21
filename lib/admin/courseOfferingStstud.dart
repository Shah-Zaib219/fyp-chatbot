import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'appBar.dart';
class CourseOfferingTogglePage extends StatefulWidget {
  @override
  _CourseOfferingTogglePageState createState() =>
      _CourseOfferingTogglePageState();
}

class _CourseOfferingTogglePageState extends State<CourseOfferingTogglePage> {
  String status = 'yes';
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
        isLoading = false;
      });
    }
  }

  Future<void> toggleStatus() async {
    final newStatus = (status == 'yes') ? 'no' : 'yes';

    final response = await http.post(
      Uri.parse('http://localhost/html/update_course_offering.php'),
      body: {'id': '1', 'status': newStatus},
    );

    final data = json.decode(response.body);

    if (data['status'] == 'success') {
      setState(() {
        status = newStatus;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: ${data['message']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: buildAdminProfileAppBar(context, "Course Offering Toggle"),

      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                padding: EdgeInsets.all(24),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Course Offering is currently:',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: status == 'yes'
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: toggleStatus,
                      icon: Icon(Icons.sync),
                      label: Text('Toggle Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
