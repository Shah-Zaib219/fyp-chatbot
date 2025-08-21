import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'appbar.dart';

class SolveConflictScreen extends StatefulWidget {
  final String regno;
  final List<String> selectedCourses;
  final List<Map<String, dynamic>> eligibleCourses;

  const SolveConflictScreen({
    Key? key,
    required this.regno,
    required this.selectedCourses,
    required this.eligibleCourses,
  }) : super(key: key);

  @override
  State<SolveConflictScreen> createState() => _SolveConflictScreenState();
}

class _SolveConflictScreenState extends State<SolveConflictScreen> {
  Map<String, List<Map<String, dynamic>>> courseSections = {};
  Map<String, Map<String, dynamic>> selectedSections = {};
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> timetable = [];
  Map<String, List<String>> timeConflicts = {};
  bool isRegistering = false;

  @override
  void initState() {
    super.initState();
    fetchAllSections();
  }

  Future<void> fetchAllSections() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse('http://localhost/html/getcoursessections.php');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'regno': widget.regno,
              'courses': widget.selectedCourses,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          throw Exception(data['error']);
        }

        setState(() {
          courseSections = {};
          for (var section in data['sections']) {
            final courseCode = section['course_code'];
            courseSections.putIfAbsent(courseCode, () => []).add(section);
          }

          // Initialize with first available section for each course
          selectedSections = {};
          for (var courseCode in widget.selectedCourses) {
            if (courseSections.containsKey(courseCode) &&
                courseSections[courseCode]!.isNotEmpty) {
              selectedSections[courseCode] = courseSections[courseCode]!.first;
            }
          }

          isLoading = false;
        });

        generateTimetable();
      } else {
        throw Exception('Failed to load sections: ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timed out. Please try again.';
        isLoading = false;
      });
    } on SocketException {
      setState(() {
        errorMessage = 'Network error. Please check your connection.';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void generateTimetable() {
    List<Map<String, dynamic>> newTimetable = [];
    Map<String, List<String>> newConflicts = {};

    // Convert all timetable entries to comparable format
    for (var entry in selectedSections.entries) {
      final courseCode = entry.key;
      final section = entry.value;

      if (section['timetable'] != null) {
        for (var slot in section['timetable']) {
          newTimetable.add({
            'course_code': courseCode,
            'section_id': section['section_id'],
            'day': slot['day'],
            'start_time': slot['start_time'],
            'end_time': slot['end_time'],
            'room': slot['room'],
          });
        }
      }
    }

    // Detect conflicts
    for (int i = 0; i < newTimetable.length; i++) {
      for (int j = i + 1; j < newTimetable.length; j++) {
        final slot1 = newTimetable[i];
        final slot2 = newTimetable[j];

        if (slot1['day'] == slot2['day'] &&
            isTimeOverlap(
              slot1['start_time'],
              slot1['end_time'],
              slot2['start_time'],
              slot2['end_time'],
            )) {
          newConflicts
              .putIfAbsent(slot1['course_code'], () => [])
              .add(slot2['course_code']);
          newConflicts
              .putIfAbsent(slot2['course_code'], () => [])
              .add(slot1['course_code']);
        }
      }
    }

    setState(() {
      timetable = newTimetable;
      timeConflicts = newConflicts;
    });
  }

  bool isTimeOverlap(String start1, String end1, String start2, String end2) {
    final startTime1 =
        TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 $start1'));
    final endTime1 = TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 $end1'));
    final startTime2 =
        TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 $start2'));
    final endTime2 = TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 $end2'));

    return (startTime1.hour * 60 + startTime1.minute) <
            (endTime2.hour * 60 + endTime2.minute) &&
        (endTime1.hour * 60 + endTime1.minute) >
            (startTime2.hour * 60 + startTime2.minute);
  }

  void _onSectionSelected(String courseCode, Map<String, dynamic> section) {
    setState(() {
      selectedSections[courseCode] = section;
    });
    generateTimetable();
  }

  Future<void> _registerSelectedSections() async {
    if (timeConflicts.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please resolve all time conflicts before registering'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isRegistering = true);

    try {
      final url = Uri.parse('http://localhost/html/registercourses.php');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'regno': widget.regno,
              'sections':
                  selectedSections.values.map((s) => s['section_id']).toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) throw Exception(data['error']);

        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildStudentProfileAppBar(context, "Solve Conflicts", widget.regno),
      body: _buildBody(),
      floatingActionButton: _buildRegisterButton(),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return _buildErrorView();
    return _buildMainContent();
  }

  Widget _buildErrorView() {
    return Center(
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
            onPressed: fetchAllSections,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildConflictStatus(),
        Expanded(child: _buildCourseSectionsList()),
      ],
    );
  }

  Widget _buildConflictStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: timeConflicts.isEmpty ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: timeConflicts.isEmpty ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            timeConflicts.isEmpty ? Icons.check_circle : Icons.warning,
            color: timeConflicts.isEmpty ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              timeConflicts.isEmpty
                  ? 'No schedule conflicts detected'
                  : '${timeConflicts.length} conflict(s) detected - Please resolve before registering',
              style: TextStyle(
                color:
                    timeConflicts.isEmpty ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSectionsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        ...widget.selectedCourses.map((courseCode) {
          final course = widget.eligibleCourses.firstWhere(
            (c) => c['code'] == courseCode,
            orElse: () => {'title': 'Unknown Course'},
          );
          final isConflicted = timeConflicts.containsKey(courseCode);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isConflicted ? Colors.red : Colors.transparent,
                width: 2,
              ),
            ),
            child: ExpansionTile(
              title: Text(
                '$courseCode - ${course['title']}',
                style: TextStyle(
                  color: isConflicted ? Colors.red[900] : Colors.blue[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                isConflicted ? 'Conflict detected!' : 'No conflicts',
                style: TextStyle(
                  color: isConflicted ? Colors.red : Colors.green,
                ),
              ),
              children: _buildSectionOptions(courseCode, isConflicted),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        _buildTimetablePreview(),
      ],
    );
  }

  List<Widget> _buildSectionOptions(String courseCode, bool isConflicted) {
    if (courseSections[courseCode] == null ||
        courseSections[courseCode]!.isEmpty) {
      return [
        const ListTile(
          title: Text('No sections available',
              style: TextStyle(color: Colors.grey)),
        ),
      ];
    }

    return courseSections[courseCode]!.map((section) {
      final isSelected =
          selectedSections[courseCode]?['section_id'] == section['section_id'];
      final hasConflict = isConflicted &&
          timeConflicts[courseCode]!.any((conflictCourse) =>
              selectedSections[conflictCourse]?['section_id'] ==
              section['section_id']);

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: hasConflict
            ? Colors.red[50]
            : (isSelected ? Colors.blue[50] : null),
        child: ListTile(
          title: Text(
            'Section ${section['section_name']}',
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: hasConflict ? Colors.red[900] : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section['faculty_name'] != null)
                Text('Faculty: ${section['faculty_name']}'),
              ..._buildTimetableInfo(section['timetable']),
            ],
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          onTap: () => _onSectionSelected(courseCode, section),
        ),
      );
    }).toList();
  }

  List<Widget> _buildTimetableInfo(List<dynamic>? timetable) {
    if (timetable == null || timetable.isEmpty) {
      return [
        const Text('No schedule available',
            style: TextStyle(color: Colors.grey))
      ];
    }

    return timetable.map<Widget>((slot) {
      return Text(
        '${slot['day']}: ${slot['start_time']}-${slot['end_time']} (${slot['room']})',
        style: const TextStyle(fontSize: 12),
      );
    }).toList();
  }

  Widget _buildTimetablePreview() {
    if (timetable.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Your Weekly Schedule:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 3,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: _buildDayColumns(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDayColumns() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return days.map((day) {
      final daySlots = timetable.where((slot) => slot['day'] == day).toList();
      if (daySlots.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ...daySlots.map((slot) {
            final isConflicted = timeConflicts.containsKey(slot['course_code']);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isConflicted ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isConflicted ? Colors.red : Colors.green,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${slot['start_time']}-${slot['end_time']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${slot['course_code']} (${slot['room']})',
                      style: TextStyle(
                        color:
                            isConflicted ? Colors.red[900] : Colors.green[900],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const Divider(),
        ],
      );
    }).toList();
  }

  Widget _buildRegisterButton() {
    return FloatingActionButton.extended(
      onPressed: timeConflicts.isEmpty ? _registerSelectedSections : null,
      backgroundColor: timeConflicts.isEmpty ? Colors.blue[800] : Colors.grey,
      icon: isRegistering
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.check_circle, color: Colors.white),
      label: const Text(
        'Register Selected',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
