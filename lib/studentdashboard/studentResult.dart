import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'appbar.dart';

class StudentResultPage extends StatefulWidget {
  final String regNo;

  const StudentResultPage({super.key, required this.regNo});

  @override
  State<StudentResultPage> createState() => _StudentResultPageState();
}

class _StudentResultPageState extends State<StudentResultPage> {
  List<dynamic> courses = [];
  bool isLoading = true;
  String errorMessage = '';

  final Color darkBlue = const Color(0xFF071931); // Dashboard color

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost/html/get_student_result.php?regno=${widget.regNo}'));

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          courses = data['courses'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Failed to load result';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Widget buildSemesterWiseTables() {
    if (courses.isEmpty) {
      return Center(
        child: Text(
          "No results found.",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Group courses by semester
    Map<String, List<dynamic>> semesterCourses = {};
    for (var course in courses) {
      String semester = course['semester'].toString();
      semesterCourses.putIfAbsent(semester, () => []).add(course);
    }

    List<Widget> semesterWidgets = [];

    semesterCourses.forEach((semester, courseList) {
      semesterWidgets.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semester: $semester',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(4),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(2),
            },
            border: TableBorder.all(color: Colors.grey.shade300),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.blue[800]),
                children: [
                  tableHeader("Code"),
                  tableHeader("Title"),
                  tableHeader("CrHr"),
                  tableHeader("Grade"),
                  tableHeader("Points"),
                ],
              ),
              ...courseList.map((course) {
                return TableRow(
                  decoration: BoxDecoration(color: Colors.white),
                  children: [
                    tableCell(course['course_code'] ?? '-'),
                    tableCell(course['course_title'] ?? '-', wrap: true),
                    tableCell(course['credit_hours'].toString()),
                    tableCell(course['grade'] ?? '-'),
                    tableCell(course['grade_points']?.toString() ?? '-'),
                  ],
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[400], thickness: 1.2),
          const SizedBox(height: 16),
        ],
      ));
    });

    return Column(children: semesterWidgets);
  }

  Widget tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget tableCell(String text, {bool wrap = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        textAlign: TextAlign.center,
        softWrap: wrap,
        overflow: wrap ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:
          buildStudentProfileAppBar(context, "Semesters Result", widget.regNo),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: SingleChildScrollView(
                child: buildSemesterWiseTables(),
              ),
            ),
    );
  }
}
