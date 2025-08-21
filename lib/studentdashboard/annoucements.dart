import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'appbar.dart';

class AnnouncementsPage extends StatefulWidget {
  final String regno;
  AnnouncementsPage({super.key, required this.regno});

  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  List<dynamic> announcements = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/html/fetchann.php'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            announcements = data['announcements'];
            isLoading = false;
            errorMessage = '';
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'No announcements available';
          });
        }
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load announcements: ${e.toString()}';
      });
    }
  }

  String _getTargetDescription(dynamic announcement) {
    switch (announcement['target']) {
      case 'all':
        return 'For all students';
      case 'program':
        return 'For your program';
      case 'batch':
        return 'For your batch';
      case 'section':
        return 'For your section';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStudentProfileAppBar(context, "Announcements", widget.regno),
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchAnnouncements,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: announcements.length + 1, // +1 for local card
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Local announcement
                        return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      child: Text(
                                        'A',
                                        style: TextStyle(
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Admin',
                                            style: TextStyle(
                                              color: Colors.blue[800],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Jul 1, 2025 08:30 AM',
                                            style: TextStyle(
                                              color: Colors.blue[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/image/announcement.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Admission Fall 2025',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Last Date for Submission of Applications is 9th July.',
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Valid until: 2025-07-09',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // Server announcement
                        final announcement = announcements[index - 1];

                        return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      child: Text(
                                        announcement['posted_by'][0]
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            announcement['posted_by'] ??
                                                'Admin',
                                            style: TextStyle(
                                              color: Colors.blue[800],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            announcement['post_date'] ?? '',
                                            style: TextStyle(
                                              color: Colors.blue[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Chip(
                                  label: Text(
                                    _getTargetDescription(announcement),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue[800],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  announcement['title'] ?? 'No title',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  announcement['content'] ?? 'No content',
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                  ),
                                ),
                                if (announcement['expiry_date'] != null) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    'Valid until: ${announcement['expiry_date']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchAnnouncements,
        backgroundColor: Colors.blue[800],
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
