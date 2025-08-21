// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'appBar.dart';

// class UploadAnnouncementScreen extends StatefulWidget {
//   final String username;
//   final int adminId;
//   final int departmentId;

//   const UploadAnnouncementScreen({
//     super.key,
//     required this.username,
//     required this.adminId,
//     required this.departmentId,
//   });

//   @override
//   _UploadAnnouncementScreenState createState() =>
//       _UploadAnnouncementScreenState();
// }

// class _UploadAnnouncementScreenState extends State<UploadAnnouncementScreen> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descController = TextEditingController();
//   String _message = "";
//   Color _messageColor = Colors.black;
//   bool _isLoading = false;
//   bool _isFetchingBatches = false;
//   final _formKey = GlobalKey<FormState>();

//   // Batch selection
//   String? _selectedBatch;
//   List<String> _batches = [];
//   List<Map<String, dynamic>> _batchData = [];

//   // API configuration
//   final String _baseUrl = "http://localhost/html";
//   final Duration _apiTimeout = const Duration(seconds: 10);

//   @override
//   void initState() {
//     super.initState();
//     _fetchBatches();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchBatches() async {
//     try {
//       final response = await http
//           .get(Uri.parse('$_baseUrl/fetch_batches.php'))
//           .timeout(Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'success') {
//           setState(() {
//             _batches = List<String>.from(data['batches']);
//             if (_batches.isNotEmpty) {
//               _selectedBatch = _batches.first;
//             }
//           });
//         }
//       }
//     } catch (e) {
//       // Fallback default values
//       setState(() {
//         _batches = ['FA20', 'SP21', 'FA21'];
//         _selectedBatch = _batches.first;
//       });
//     } finally {
//       setState(() {
//         _isFetchingBatches = false;
//       });
//     }
//   }

//   Future<void> uploadAnnouncement() async {
//     if (!_formKey.currentState!.validate()) {
//       setState(() {
//         _message = "Please fill all required fields";
//         _messageColor = Colors.red;
//       });
//       return;
//     }

//     if (_selectedBatch == null || _selectedBatch!.isEmpty) {
//       setState(() {
//         _message = "Please select a valid batch";
//         _messageColor = Colors.red;
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _message = "";
//     });

//     try {
//       final Map<String, dynamic> requestBody = {
//         'title': _titleController.text.trim(),
//         'content': _descController.text.trim(),
//         'posted_by': widget.adminId.toString(),
//         'target': _selectedBatch == 'All' ? 'all' : 'batch',
//         'target_id': _selectedBatch,
//       };

//       final response = await http
//           .post(
//             Uri.parse("$_baseUrl/post.php"),
//             headers: {
//               "Content-Type": "application/json",
//               "Accept": "application/json",
//             },
//             body: jsonEncode(requestBody),
//           )
//           .timeout(_apiTimeout);

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         setState(() {
//           _message =
//               responseData['message'] ?? 'Announcement posted successfully';
//           _messageColor =
//               responseData['status'] == "success" ? Colors.green : Colors.red;

//           if (responseData['status'] == "success") {
//             _titleController.clear();
//             _descController.clear();
//             _formKey.currentState?.reset();
//           }
//         });
//       } else {
//         throw Exception(
//             responseData['error'] ?? 'Server error ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         _message = "Error: ${e.toString().replaceAll('Exception:', '').trim()}";
//         _messageColor = Colors.red;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: buildAdminProfileAppBar(context, "Post Announcements"),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Batch selection dropdown
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue.shade800),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12),
//                 child: DropdownButtonFormField<String>(
//                   value: _selectedBatch,
//                   items: _batches.map<DropdownMenuItem<String>>((String batch) {
//                     return DropdownMenuItem<String>(
//                       value: batch,
//                       child: Text(batch),
//                     );
//                   }).toList(),
//                   onChanged: (String? value) =>
//                       setState(() => _selectedBatch = value),
//                   decoration: InputDecoration(
//                     labelText: "Batch",
//                     border: InputBorder.none,
//                   ),
//                   isExpanded: true,
//                   validator: (value) =>
//                       value == null ? 'Please select a batch' : null,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Title field
//               TextFormField(
//                 controller: _titleController,
//                 decoration: InputDecoration(
//                   labelText: "Title*",
//                   prefixIcon: Icon(Icons.title),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blue.shade800),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) => value == null || value.trim().isEmpty
//                     ? 'Title is required'
//                     : null,
//               ),
//               const SizedBox(height: 20),

//               // Description field
//               TextFormField(
//                 controller: _descController,
//                 maxLines: 5,
//                 decoration: InputDecoration(
//                   labelText: "Description*",
//                   alignLabelWithHint: true,
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blue.shade800),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) => value == null || value.trim().isEmpty
//                     ? 'Description is required'
//                     : null,
//               ),
//               const SizedBox(height: 30),

//               // Submit button
//               ElevatedButton(
//                 onPressed: _isLoading ? null : uploadAnnouncement,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   backgroundColor: Colors.blue.shade800,
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'POST ANNOUNCEMENT',
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//               ),
//               const SizedBox(height: 20),

//               // Message display
//               if (_message.isNotEmpty)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: _messageColor.withOpacity(0.1),
//                     border: Border.all(color: _messageColor),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         _messageColor == Colors.green
//                             ? Icons.check_circle
//                             : Icons.error,
//                         color: _messageColor,
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           _message,
//                           style: TextStyle(color: _messageColor),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'appBar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io; // only used on non-web

class UploadAnnouncementScreen extends StatefulWidget {
  final String username;
  final int adminId;
  final int departmentId;

  const UploadAnnouncementScreen({
    super.key,
    required this.username,
    required this.adminId,
    required this.departmentId,
  });

  @override
  _UploadAnnouncementScreenState createState() =>
      _UploadAnnouncementScreenState();
}

class _UploadAnnouncementScreenState extends State<UploadAnnouncementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _message = "";
  Color _messageColor = Colors.black;
  bool _isLoading = false;
  bool _isFetchingBatches = false;
  final _formKey = GlobalKey<FormState>();

  // Image (for web/mobile)
  Uint8List? _webImageBytes;
  String? _webImageName;
  io.File? _localImage;

  // Batch selection
  String? _selectedBatch;
  List<String> _batches = [];

  final String _baseUrl = "http://localhost/html";
  final Duration _apiTimeout = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _fetchBatches();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _fetchBatches() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/fetch_batches.php'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _batches = List<String>.from(data['batches']);
            _selectedBatch = _batches.isNotEmpty ? _batches.first : null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _batches = ['FA20', 'SP21', 'FA21'];
        _selectedBatch = _batches.first;
      });
    } finally {
      setState(() {
        _isFetchingBatches = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      if (kIsWeb) {
        setState(() {
          _webImageBytes = result.files.single.bytes!;
          _webImageName = result.files.single.name;
        });
      } else {
        setState(() {
          _localImage = io.File(result.files.single.path!);
        });
      }
    }
  }

  Future<void> uploadAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _message = "Please fill all required fields";
        _messageColor = Colors.red;
      });
      return;
    }

    if (_selectedBatch == null || _selectedBatch!.isEmpty) {
      setState(() {
        _message = "Please select a valid batch";
        _messageColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = "";
    });

    try {
      var uri = Uri.parse("$_baseUrl/post.php");
      var request = http.MultipartRequest("POST", uri);

      request.fields['title'] = _titleController.text.trim();
      request.fields['content'] = _descController.text.trim();
      request.fields['posted_by'] = widget.adminId.toString();
      request.fields['target'] = _selectedBatch == 'All' ? 'all' : 'batch';
      request.fields['target_id'] = _selectedBatch!;

      if (kIsWeb && _webImageBytes != null && _webImageName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _webImageBytes!,
          filename: _webImageName!,
        ));
      } else if (!kIsWeb && _localImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _localImage!.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      setState(() {
        _message = responseData['message'] ?? 'Uploaded';
        _messageColor =
            responseData['status'] == "success" ? Colors.green : Colors.red;
      });

      if (responseData['status'] == "success") {
        _titleController.clear();
        _descController.clear();
        _formKey.currentState?.reset();
        _localImage = null;
        _webImageBytes = null;
        _webImageName = null;
      }
    } catch (e) {
      setState(() {
        _message = "Upload failed: ${e.toString()}";
        _messageColor = Colors.red;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAdminProfileAppBar(context, "Post Announcements"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedBatch,
                items: _batches.map((batch) {
                  return DropdownMenuItem(value: batch, child: Text(batch));
                }).toList(),
                onChanged: (value) => setState(() => _selectedBatch = value),
                decoration: InputDecoration(
                  labelText: "Batch",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Please select a batch' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Title*",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Description*",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text("Select Image"),
              ),
              const SizedBox(height: 10),
              if (_webImageBytes != null)
                Image.memory(_webImageBytes!, height: 150),
              if (_localImage != null) Image.file(_localImage!, height: 150),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : uploadAnnouncement,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("POST ANNOUNCEMENT"),
              ),
              const SizedBox(height: 20),
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _messageColor.withOpacity(0.1),
                    border: Border.all(color: _messageColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _messageColor == Colors.green
                            ? Icons.check_circle
                            : Icons.error,
                        color: _messageColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_message)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
