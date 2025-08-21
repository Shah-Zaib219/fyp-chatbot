import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // For File
import 'appBar.dart';

class ChatbotPDFScreen extends StatefulWidget {
  final String adminUsername;

  const ChatbotPDFScreen({super.key, required this.adminUsername});

  @override
  _ChatbotPDFScreenState createState() => _ChatbotPDFScreenState();
}

class _ChatbotPDFScreenState extends State<ChatbotPDFScreen> {
  List documents = [];

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost/html/fetch_chatbot_pdfs.php"),
      );
      final data = json.decode(response.body);
      if (data['status'] == "success") {
        setState(() {
          documents = data['documents'];
        });
      }
    } catch (e) {
      print("Error fetching documents: $e");
    }
  }

  Future<void> uploadPDF() async {
    String selectedDepartment = "CS";
    TextEditingController sessionStart = TextEditingController();
    TextEditingController sessionEnd = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Upload Chatbot PDF"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDepartment,
                      decoration:
                          const InputDecoration(labelText: "Department"),
                      items: ['CS', 'SE'].map((d) {
                        return DropdownMenuItem<String>(
                          value: d,
                          child: Text(d),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedDepartment = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sessionStart,
                      decoration:
                          const InputDecoration(labelText: "Session Start"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sessionEnd,
                      decoration: const InputDecoration(
                          labelText: "Session End (optional)"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (sessionStart.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Session Start is required")),
                      );
                      return;
                    }

                    try {
                      // Replace this path with the actual location of dummy.pdf on device or assets
                      File dummyFile =
                          File("/storage/emulated/0/Download/dummy.pdf");

                      if (!await dummyFile.exists()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Dummy PDF not found on device")),
                        );
                        return;
                      }

                      var request = http.MultipartRequest(
                        'POST',
                        Uri.parse(
                            "http://localhost/html/upload_chatbot_pdf.php"),
                      );

                      request.files.add(
                        await http.MultipartFile.fromPath(
                          'pdf',
                          dummyFile.path,
                        ),
                      );

                      request.fields['department'] = selectedDepartment;
                      request.fields['session_start'] =
                          sessionStart.text.trim();
                      request.fields['session_end'] = sessionEnd.text.trim();
                      request.fields['added_by'] = widget.adminUsername;

                      final response = await request.send();
                      final responseBody =
                          await response.stream.bytesToString();
                      final resultData = json.decode(responseBody);

                      if (resultData['status'] == "success") {
                        Navigator.pop(context);
                        fetchDocuments();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(resultData['message'] ?? "Upload failed"),
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: const Text("Upload"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void openPDF(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening document not implemented")),
    );
    // You can use `open_file` package here if needed
    // or integrate PDF Viewer plugin
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAdminProfileAppBar(context, "Add ChatBot Document"),
      body: documents.isEmpty
          ? const Center(child: Text("No documents available"))
          : ListView.builder(
              itemCount: documents.length,
              itemBuilder: (_, index) {
                final doc = documents[index];
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading:
                        const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(
                        "Session: ${doc['session_start']} - ${doc['session_end'] ?? "Present"}"),
                    subtitle: Text(
                        "Department: ${doc['department']} | Added by: ${doc['added_by']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                        openPDF(doc['pdf_url'] ?? "");
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadPDF,
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
