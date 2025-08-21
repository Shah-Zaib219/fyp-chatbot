// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'appBar.dart';

// class AdminAnnouncementsPage extends StatefulWidget {
//   @override
//   _AdminAnnouncementsPageState createState() => _AdminAnnouncementsPageState();
// }

// class _AdminAnnouncementsPageState extends State<AdminAnnouncementsPage> {
//   List<dynamic> announcements = [];
//   bool isLoading = true;
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchAnnouncements();
//   }

//   Future<void> fetchAnnouncements() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost/html/adminannouncements.php'),
//       );
//       final data = json.decode(response.body);

//       if (data['status'] == 'success') {
//         setState(() {
//           announcements = data['announcements'];
//           isLoading = false;
//           errorMessage = '';
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           errorMessage = data['message'] ?? 'No announcements available';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage = 'Error: ${e.toString()}';
//       });
//     }
//   }

//   Future<void> confirmDelete(int id) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Confirm Delete"),
//         content: Text("Are you sure you want to delete this announcement?"),
//         actions: [
//           TextButton(
//             child: Text("Cancel"),
//             onPressed: () => Navigator.pop(context, false),
//           ),
//           TextButton(
//             child: Text("Delete", style: TextStyle(color: Colors.red)),
//             onPressed: () => Navigator.pop(context, true),
//           ),
//         ],
//       ),
//     );
//     if (confirmed == true) {
//       deleteAnnouncement(id);
//     }
//   }

//   Future<void> deleteAnnouncement(int id) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost/html/delete_announcement.php'),
//         body: {'id': id.toString()},
//       );
//       final data = json.decode(response.body);

//       if (data['status'] == 'success') {
//         fetchAnnouncements();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['message'] ?? 'Delete failed')),
//         );
//       }
//     } catch (e) {
//       print('Delete error: $e');
//     }
//   }

//   void navigateToEditScreen(dynamic announcement) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => EditAnnouncementPage(
//           announcement: announcement,
//           onUpdate: fetchAnnouncements,
//         ),
//       ),
//     );
//   }

//   String _getTargetDescription(dynamic a) {
//     switch (a['target']) {
//       case 'all':
//         return 'For all students';
//       case 'program':
//         return 'For your program';
//       case 'batch':
//         return 'For your batch';
//       case 'section':
//         return 'For your section';
//       default:
//         return 'Unknown';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: buildAdminProfileAppBar(context, "Manage Announcements"),
//       backgroundColor: Colors.grey[100],
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(
//                   child: Text(
//                     errorMessage,
//                     style: TextStyle(color: Colors.blue[800]),
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: fetchAnnouncements,
//                   child: ListView.builder(
//                     padding: EdgeInsets.all(12),
//                     itemCount: announcements.length,
//                     itemBuilder: (context, index) {
//                       final a = announcements[index];
//                       return Container(
//                         margin: EdgeInsets.symmetric(vertical: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 4,
//                               offset: Offset(0, 2),
//                             )
//                           ],
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           a['title'] ?? 'No Title',
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.blue[800],
//                                           ),
//                                         ),
//                                         SizedBox(height: 4),
//                                         Text(
//                                           a['post_date'] ?? '',
//                                           style: TextStyle(
//                                             color: Colors.blue[400],
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: Icon(Icons.edit,
//                                         color: Colors.blue[800]),
//                                     onPressed: () => navigateToEditScreen(a),
//                                   ),
//                                   IconButton(
//                                     icon: Icon(Icons.delete,
//                                         color: Colors.red[700]),
//                                     onPressed: () =>
//                                         confirmDelete(a['id'] as int),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 a['content'] ?? 'No content',
//                                 style: TextStyle(color: Colors.blue[900]),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 _getTargetDescription(a),
//                                 style: TextStyle(
//                                     fontStyle: FontStyle.italic,
//                                     color: Colors.grey[600]),
//                               ),
//                               if (a['expiry_date'] != null) ...[
//                                 SizedBox(height: 4),
//                                 Text(
//                                   'Valid until: ${a['expiry_date']}',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                       fontStyle: FontStyle.italic),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }
// }

// class EditAnnouncementPage extends StatefulWidget {
//   final dynamic announcement;
//   final VoidCallback onUpdate;

//   EditAnnouncementPage({
//     required this.announcement,
//     required this.onUpdate,
//   });

//   @override
//   _EditAnnouncementPageState createState() => _EditAnnouncementPageState();
// }

// class _EditAnnouncementPageState extends State<EditAnnouncementPage> {
//   late TextEditingController titleController;
//   late TextEditingController contentController;

//   @override
//   void initState() {
//     super.initState();
//     titleController = TextEditingController(text: widget.announcement['title']);
//     contentController =
//         TextEditingController(text: widget.announcement['content']);
//   }

//   Future<void> updateAnnouncement() async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost/html/update_announcement.php'),
//         body: {
//           'id': widget.announcement['id'].toString(),
//           'title': titleController.text,
//           'content': contentController.text,
//         },
//       );
//       final data = json.decode(response.body);
//       if (data['status'] == 'success') {
//         widget.onUpdate();
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['message'] ?? 'Update failed')),
//         );
//       }
//     } catch (e) {
//       print('Update error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: buildAdminProfileAppBar(context, "Manage Announcements"),
//       backgroundColor: Colors.grey[100],
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: titleController,
//               decoration: InputDecoration(
//                 labelText: 'Title',
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: contentController,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 labelText: 'Content',
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: updateAnnouncement,
//               child: Text('Update Announcement'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[800],
//                 foregroundColor: Colors.white,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'appBar.dart';

class AdminAnnouncementsPage extends StatefulWidget {
  @override
  _AdminAnnouncementsPageState createState() => _AdminAnnouncementsPageState();
}

class _AdminAnnouncementsPageState extends State<AdminAnnouncementsPage> {
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
      final response = await http.get(
        Uri.parse('http://localhost/html/adminannouncements.php'),
      );
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          announcements = data['announcements'];
          isLoading = false;
          errorMessage = '';
        });
        for (var a in announcements) print(a['image_url']);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = data['message'] ?? 'No announcements available';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this announcement?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      deleteAnnouncement(id);
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/html/delete_announcement.php'),
        body: {'id': id.toString()},
      );
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        fetchAnnouncements();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Delete failed')),
        );
      }
    } catch (e) {
      print('Delete error: $e');
    }
  }

  void navigateToEditScreen(dynamic announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAnnouncementPage(
          announcement: announcement,
          onUpdate: fetchAnnouncements,
        ),
      ),
    );
  }

  String _getTargetDescription(dynamic a) {
    switch (a['target']) {
      case 'all':
        return 'For all students';
      case 'program':
        return 'For your program';
      case 'batch':
        return 'For your batch';
      case 'section':
        return 'For your section';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAdminProfileAppBar(context, "Manage Announcements"),
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
                    padding: EdgeInsets.all(12),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final a = announcements[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a['title'] ?? 'No Title',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          a['post_date'] ?? '',
                                          style: TextStyle(
                                            color: Colors.blue[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.blue[800]),
                                    onPressed: () => navigateToEditScreen(a),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red[700]),
                                    onPressed: () =>
                                        confirmDelete(a['id'] as int),
                                  ),
                                ],
                              ),
                            ),
                            if (a['image_url'] != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.zero,
                                    bottom: Radius.circular(8)),
                                child: Image.network(
                                  "http://10.125.76.114/html/uploads/announcements/WhatsApp Image 2025-07-08 at 11.53.30 PM.jpeg",
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('Image not found',
                                          style: TextStyle(color: Colors.red)),
                                    );
                                  },
                                ),
                              ),
                            ],
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a['content'] ?? 'No content',
                                    style: TextStyle(color: Colors.blue[900]),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _getTargetDescription(a),
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (a['expiry_date'] != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      'Valid until: ${a['expiry_date']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class EditAnnouncementPage extends StatefulWidget {
  final dynamic announcement;
  final VoidCallback onUpdate;

  EditAnnouncementPage({
    required this.announcement,
    required this.onUpdate,
  });

  @override
  _EditAnnouncementPageState createState() => _EditAnnouncementPageState();
}

class _EditAnnouncementPageState extends State<EditAnnouncementPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.announcement['title']);
    contentController =
        TextEditingController(text: widget.announcement['content']);
  }

  Future<void> updateAnnouncement() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/html/update_announcement.php'),
        body: {
          'id': widget.announcement['id'].toString(),
          'title': titleController.text,
          'content': contentController.text,
        },
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        widget.onUpdate();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Update failed')),
        );
      }
    } catch (e) {
      print('Update error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAdminProfileAppBar(context, "Manage Announcements"),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Content',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: updateAnnouncement,
              child: Text('Update Announcement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
