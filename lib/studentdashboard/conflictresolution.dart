import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'appbar.dart';
import 'solveconflict.dart';

class ConflictResolutionScreen extends StatefulWidget {
  final String regno;
  const ConflictResolutionScreen({Key? key, required this.regno})
      : super(key: key);

  @override
  State<ConflictResolutionScreen> createState() =>
      _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState extends State<ConflictResolutionScreen> {
  List<Map<String, dynamic>> eligibleCourses = [];
  Map<String, bool> selectedCourses = {};
  bool isLoading = true;
  String? errorMessage;
  int totalCredits = 0;
  String studentType = 'regular';
  int selectedCredits = 0;

  @override
  void initState() {
    super.initState();
    fetchEligibleCourses();
  }

  Future<void> fetchEligibleCourses() async {
    try {
      final url = Uri.parse(
          'http://localhost/html/getcourses.php?regno=${widget.regno}');
      if (kDebugMode) {
        print('Fetching courses from: $url');
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

        final uniqueCoursesMap = <String, Map<String, dynamic>>{};
        for (var course in data['courses']) {
          uniqueCoursesMap[course['code']] = course;
        }

        setState(() {
          eligibleCourses = uniqueCoursesMap.values.toList();
          totalCredits = data['total_credits'] as int;
          studentType = data['student_type'] ?? 'regular';
          selectedCourses = {};
          for (var course in eligibleCourses) {
            selectedCourses[course['code']] = false;
          }
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load courses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching courses: $e');
      }
    }
  }

  void _onCourseSelected(String courseCode, bool? value) {
    if (value == null) return;

    final course = eligibleCourses.firstWhere((c) => c['code'] == courseCode);
    final courseCredits = course['credit_hours'] as int;
    final newSelectedCredits =
        selectedCredits + (value ? courseCredits : -courseCredits);

    if (newSelectedCredits > 21) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot exceed 21 credit hours'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      selectedCourses[courseCode] = value;
      selectedCredits = newSelectedCredits;
    });
  }

  Future<void> _handleCourseRegistration() async {
    if (selectedCourses.values.every((isSelected) => !isSelected)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one course')),
      );
      return;
    }

    final selected = selectedCourses.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (studentType == 'regular') {
      _showRegularStudentConfirmation(selected);
    } else {
      _navigateToConflictResolution(selected);
    }
  }

  void _showRegularStudentConfirmation(List<String> selectedCourses) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text(
            'Your courses will be registered automatically as you are a regular student.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _registerCourses(selectedCourses);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _navigateToConflictResolution(List<String> selectedCourses) {
    // Get full course details for selected courses
    List<Map<String, dynamic>> selectedCourseDetails = [];
    for (var courseCode in selectedCourses) {
      var course = eligibleCourses.firstWhere((c) => c['code'] == courseCode);
      selectedCourseDetails.add(course);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolveConflictScreen(
          regno: widget.regno,
          selectedCourses: selectedCourses,
          eligibleCourses:
              selectedCourseDetails, // Pass only selected courses with full details
        ),
      ),
    );
  }

  Future<void> _registerCourses(List<String> courseCodes) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Courses registered successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:
          buildStudentProfileAppBar(context, "Offered Courses", widget.regno),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Type and Credits Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Student Type: ${studentType.toUpperCase()}',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Selected Credits: $selectedCredits/21', // Changed from totalCredits to selectedCredits
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select courses for registration:',
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                      onPressed: fetchEligibleCourses,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                      ),
                      child: const Text('Retry',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )
            else if (eligibleCourses.isEmpty)
              Center(
                child: Text(
                  'No eligible courses available for registration',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: eligibleCourses.length,
                  itemBuilder: (context, index) {
                    final course = eligibleCourses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: CheckboxListTile(
                        title: Text(
                          '${course['code']} - ${course['title']}',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Credit Hours: ${course['credit_hours']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        value: selectedCourses[course['code']],
                        onChanged: (value) =>
                            _onCourseSelected(course['code'], value),
                        activeColor: Colors.blue[800],
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : _handleCourseRegistration,
        backgroundColor: Colors.blue[800],
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: const Text(
          'Solve Conflict',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ConflictResolutionDetails extends StatelessWidget {
  final String regno;
  final List<String> selectedCourses;
  final List<Map<String, dynamic>> eligibleCourses;

  const ConflictResolutionDetails({
    Key? key,
    required this.regno,
    required this.selectedCourses,
    required this.eligibleCourses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: selectedCourses.length,
      itemBuilder: (context, index) {
        final courseCode = selectedCourses[index];
        final course =
            eligibleCourses.firstWhere((c) => c['code'] == courseCode);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${course['code']} - ${course['title']}',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${course['credit_hours']} credit hours',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select alternative section:',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                // Section selection UI would go here
              ],
            ),
          ),
        );
      },
    );
  }
}
