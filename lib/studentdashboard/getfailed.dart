import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'appbar.dart';

class GetFailedCoursesScreen extends StatefulWidget {
  final String regno;
  const GetFailedCoursesScreen({Key? key, required this.regno})
      : super(key: key);

  @override
  State<GetFailedCoursesScreen> createState() => _GetFailedCoursesScreenState();
}

class _GetFailedCoursesScreenState extends State<GetFailedCoursesScreen> {
  List<Map<String, dynamic>> failedCourses = [];
  bool isLoading = true;
  String? errorMessage;
  String studentRegno = '';

  @override
  void initState() {
    super.initState();
    fetchFailedCourses();
  }

  Future<void> fetchFailedCourses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      failedCourses = [];
    });

    try {
      final url = Uri.parse(
          'http://localhost/html/getfailedcourses.php?regno=${widget.regno}');

      if (kDebugMode) {
        print('Fetching failed courses from: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] != null) {
          throw Exception(data['error']);
        }

        setState(() {
          studentRegno = data['student_regno'] ?? widget.regno;
          failedCourses =
              List<Map<String, dynamic>>.from(data['failed_courses'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load failed courses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Error: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}';
        isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching failed courses: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:
          buildStudentProfileAppBar(context, "Failed Courses - $studentRegno", widget.regno),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with student info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student: $studentRegno',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed Courses:',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: fetchFailedCourses,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                      ),
                      child: const Text('Retry',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )
            else if (failedCourses.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No failed courses found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'All courses passed successfully',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Total Failed: ${failedCourses.length} courses',
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: failedCourses.length,
                        itemBuilder: (context, index) {
                          final course = failedCourses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.red[50],
                            child: ListTile(
                              title: Text(
                                '${course['code']} - ${course['title']}',
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Semester ${course['semester']} • ${course['credit_hours']} credit hours',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Grade: ${course['grade']} (${course['marks']}%)',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (course['failure_reason'] != null)
                                    Text(
                                      'Reason: ${course['failure_reason']}',
                                      style: TextStyle(
                                        color: Colors.red[800],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing:
                                  Icon(Icons.warning, color: Colors.red[800]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchFailedCourses,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
