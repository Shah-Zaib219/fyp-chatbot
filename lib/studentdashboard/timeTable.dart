import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'appbar.dart';

class TimetableScreen extends StatefulWidget {
  final String regno;

  const TimetableScreen({Key? key, required this.regno}) : super(key: key);

  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  dynamic timetableData;
  String error = '';
  late String apiUrl;

  final Color primaryColor = Color(0xFF1565C0); // Brighter Blue
  final Color backgroundColor = Colors.grey[200]!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    apiUrl = 'http://localhost/html/timetable.php';
    fetchTimetable();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchTimetable() async {
    setState(() {
      isLoading = true;
    });
    try {
      final uri = Uri.parse('$apiUrl?regno=${widget.regno}');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          timetableData = data;
          error = data['error'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error, style: const TextStyle(color: Colors.red, fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: fetchTimetable,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableDay(String day, List<dynamic> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: primaryColor.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry['course_code'] ?? 'N/A',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor),
              ),
              const SizedBox(height: 4),
              Text(entry['course_title'] ?? '',
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${entry['start_time'] ?? ''} - ${entry['end_time'] ?? ''}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    entry['room'] ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIrregularCourses() {
    final courses = timetableData['courses'] as List;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['code'] ?? 'N/A',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor),
              ),
              const SizedBox(height: 4),
              Text(course['title'] ?? ''),
              const SizedBox(height: 4),
              Text('Faculty: ${course['faculty_name'] ?? 'Unknown'}'),
              Text('Status: ${course['status'] ?? 'Unknown'}'),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<dynamic>> _groupByDay(List<dynamic> timetable) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final grouped = <String, List<dynamic>>{};
    for (final day in days) {
      grouped[day] = [];
    }
    for (final entry in timetable) {
      grouped[entry['day']]?.add(entry);
    }
    return grouped;
  }

  Widget _buildOfflineProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No internet connection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Timetable data could not be loaded',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1565C0),
            ),
            onPressed: fetchTimetable,
            child: const Text(
              'Retry Connection',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOffline = error.contains('Connection error');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: buildStudentProfileAppBar(context, "Time Table", widget.regno),
      body: Column(
        children: [
          Container(
            color: primaryColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                  .map((day) => Tab(text: day))
                  .toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : isOffline
                    ? _buildOfflineProfile()
                    : error.isNotEmpty
                        ? _buildErrorWidget()
                        : timetableData == null
                            ? const Center(
                                child: Text('No timetable data available'),
                              )
                            : timetableData['type'] == 'irregular'
                                ? RefreshIndicator(
                                    onRefresh: fetchTimetable,
                                    child: _buildIrregularCourses(),
                                  )
                                : RefreshIndicator(
                                    onRefresh: fetchTimetable,
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        'Monday',
                                        'Tuesday',
                                        'Wednesday',
                                        'Thursday',
                                        'Friday'
                                      ]
                                          .map((day) => _buildTimetableDay(
                                              day,
                                              _groupByDay(timetableData[
                                                  'timetable'])[day]!))
                                          .toList(),
                                    ),
                                  ),
          ),
        ],
      ),
    );
  }
}
