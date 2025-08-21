// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/services.dart';

// class ChatBotScreen extends StatefulWidget {
//   final String regno;
//   const ChatBotScreen({super.key, required this.regno});

//   @override
//   _ChatBotScreenState createState() => _ChatBotScreenState();
// }

// class _ChatBotScreenState extends State<ChatBotScreen>
//     with SingleTickerProviderStateMixin {
//   List<Map<String, dynamic>> messages = [];
//   TextEditingController controller = TextEditingController();
//   ScrollController _scrollController = ScrollController();
//   bool showWelcomeMessage = true;
//   bool isPersonalGuidance = false;
//   bool isLoading = false;
//   late AnimationController _animationController;
//   late Map<String, dynamic> _resultData = {};
//   bool _isLoadingResult = false;
//   String _errorMessage = '';
//   List<Map<String, dynamic>> _courses = [];

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);
//     _fetchResult();
//     print(widget.regno);
//   }

//   Future<void> _fetchResult() async {
//     setState(() {
//       _isLoadingResult = true;
//       _errorMessage = '';
//     });

//     try {
//       final response = await http.get(
//         Uri.parse(
//             'http://localhost/html/get_student_result.php?regno=${widget.regno}'),
//         headers: {'Accept': 'application/json'},
//       ).timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'success') {
//           setState(() {
//             _resultData = data;
//             _courses = List<Map<String, dynamic>>.from(data['courses']);
//           });
//         } else {
//           throw Exception(data['message'] ?? 'Failed to fetch result');
//         }
//       } else {
//         throw Exception(
//             'Server responded with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//     } finally {
//       setState(() => _isLoadingResult = false);
//     }
//   }

//   void scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 300), () {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   void sendMessage(String text) async {
//     text = text.trim();
//     if (text.isEmpty || isLoading) return;

//     setState(() {
//       messages.add({
//         "text": text,
//         "isUser": true,
//         "timestamp": DateTime.now(),
//       });
//       showWelcomeMessage = false;
//       isLoading = true;
//     });

//     controller.clear();
//     scrollToBottom();

//     try {
//       String question = text;

//       if (isPersonalGuidance) {
//         String academicSummary = _createAcademicSummary();
//         question =
//             "[Student Query]: $text\n\n[Academic Context]: $academicSummary";
//       }

//       final response = await http.post(
//         Uri.parse('http://127.0.0.1:5600/chat'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'question': question}),
//       );

//       if (response.statusCode == 200) {
//         final responseBody = jsonDecode(response.body);
//         final reply = responseBody['answer'] ?? 'No answer received';

//         setState(() {
//           messages.add({
//             "text": reply,
//             "isUser": false,
//             "timestamp": DateTime.now(),
//           });
//         });
//       } else {
//         setState(() {
//           messages.add({
//             "text": "Error: ${response.statusCode}",
//             "isUser": false,
//             "timestamp": DateTime.now(),
//           });
//         });
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           "text": "Error: Unable to connect to server.",
//           "isUser": false,
//           "timestamp": DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//       scrollToBottom();
//     }
//   }

//   String _createAcademicSummary() {
//     if (_courses.isEmpty) return "No academic records available";

//     double totalGradePoints = 0;
//     double totalCreditHours = 0;
//     int failedCourses = 0;
//     Map<int, int> semesterPerformance = {};

//     for (var course in _courses) {
//       if (course['grade_points'] != null && course['credit_hours'] != null) {
//         totalGradePoints += (course['grade_points'] as num).toDouble() *
//             (course['credit_hours'] as num).toDouble();
//         totalCreditHours += (course['credit_hours'] as num).toDouble();

//         if (course['grade'] == 'F' ||
//             (course['marks'] != null && course['marks'] < 50)) {
//           failedCourses++;
//         }

//         int semester = (course['semester'] as num).toInt();
//         semesterPerformance[semester] =
//             (semesterPerformance[semester] ?? 0) + 1;
//       }
//     }

//     double cgpa =
//         totalCreditHours > 0 ? totalGradePoints / totalCreditHours : 0.0;
//     int highestSemester = semesterPerformance.keys
//         .fold(0, (max, semester) => semester > max ? semester : max);
//     int completedCourses = _courses.where((c) => c['grade'] != null).length;

//     // Get strengths (best performing courses)
//     var strongCourses = _courses
//         .where((c) => c['grade_points'] != null && c['grade_points'] >= 3.5)
//         .take(3)
//         .toList();

//     // Get weaknesses (worst performing courses)
//     var weakCourses = _courses
//         .where((c) => c['grade_points'] != null && c['grade_points'] < 2.5)
//         .take(3)
//         .toList();

//     return """
// Current CGPA: ${cgpa.toStringAsFixed(2)}
// Completed Courses: $completedCourses/${_courses.length}
// Failed Courses: $failedCourses
// Highest Semester: $highestSemester
// Strengths: ${strongCourses.map((c) => c['course_code']).join(', ')}
// Weaknesses: ${weakCourses.map((c) => c['course_code']).join(', ')}
// Recent Grades: ${_getRecentGrades()}
// """;
//   }

//   String _getRecentGrades() {
//     if (_courses.isEmpty) return "None";

//     int highestSemester = _courses.fold(
//         0,
//         (max, course) => (course['semester'] as num).toInt() > max
//             ? (course['semester'] as num).toInt()
//             : max);

//     var recentCourses = _courses
//         .where((c) =>
//             c['semester'] != null &&
//             (c['semester'] as num).toInt() >= highestSemester - 1 &&
//             c['grade'] != null)
//         .toList();

//     return recentCourses
//         .map((c) => "${c['course_code']}: ${c['grade']}")
//         .join(", ");
//   }

//   Widget buildMessage(Map<String, dynamic> msg) {
//     final text = msg['text'];
//     final isUser = msg['isUser'];
//     final timestamp = msg['timestamp'] as DateTime;
//     final timeStr =
//         '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

//     return GestureDetector(
//       onLongPress: () {
//         Clipboard.setData(ClipboardData(text: text));
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Message copied to clipboard'),
//             backgroundColor: Colors.blue[800],
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//         child: Row(
//           mainAxisAlignment:
//               isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (!isUser)
//               Padding(
//                 padding: const EdgeInsets.only(right: 6),
//                 child: Icon(Icons.smart_toy, size: 22, color: Colors.blue[800]),
//               ),
//             ConstrainedBox(
//               constraints: BoxConstraints(
//                 minWidth: MediaQuery.of(context).size.width * 0.15,
//                 maxWidth: MediaQuery.of(context).size.width * 0.6,
//               ),
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: isUser ? Colors.blue[800] : Colors.white,
//                   boxShadow: [
//                     if (!isUser)
//                       BoxShadow(
//                         color: Colors.blue.shade800,
//                         blurRadius: 4,
//                         offset: const Offset(2, 2),
//                       ),
//                   ],
//                   borderRadius: BorderRadius.only(
//                     topLeft: const Radius.circular(16),
//                     topRight: const Radius.circular(16),
//                     bottomLeft: Radius.circular(isUser ? 16 : 0),
//                     bottomRight: Radius.circular(isUser ? 0 : 16),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       text,
//                       style: TextStyle(
//                         color: isUser ? Colors.white : Colors.blue[900],
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Align(
//                       alignment: Alignment.bottomRight,
//                       child: Text(
//                         timeStr,
//                         style: TextStyle(
//                           color: isUser ? Colors.white70 : Colors.blue[400],
//                           fontSize: 11,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (isUser)
//               Padding(
//                 padding: const EdgeInsets.only(left: 6),
//                 child: Icon(Icons.person, size: 22, color: Colors.blue[800]),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget typingIndicator() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.grey[300],
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: List.generate(3, (index) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 2),
//               child: AnimatedBuilder(
//                 animation: _animationController,
//                 builder: (_, __) => Opacity(
//                   opacity: _animationController.value > index * 0.33 ? 1 : 0.3,
//                   child: const DotWidget(),
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final switchColor = isPersonalGuidance ? Colors.red : Colors.white;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Icon(Icons.smart_toy, color: Colors.white),
//             const SizedBox(width: 8),
//             const Text('CuiMate', style: TextStyle(color: Colors.white)),
//           ],
//         ),
//         backgroundColor: Colors.blue[800],
//         elevation: 0,
//         actions: [
//           Row(
//             children: [
//               const Text('Personal Guidance',
//                   style: TextStyle(color: Colors.white)),
//               Switch(
//                 value: isPersonalGuidance,
//                 activeColor: switchColor,
//                 onChanged: (value) =>
//                     setState(() => isPersonalGuidance = value),
//               ),
//               const SizedBox(width: 10),
//             ],
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.only(top: 12, bottom: 16),
//                   itemCount: messages.length + (isLoading ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (index == messages.length && isLoading) {
//                       return typingIndicator();
//                     }
//                     return buildMessage(messages[index]);
//                   },
//                 ),
//                 if (showWelcomeMessage)
//                   Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.chat_bubble_outline,
//                             size: 100, color: Colors.blue[800]),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'Welcome to CuiMate!\nHow can I assist you today?',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blue.shade300,
//                           blurRadius: 4,
//                           offset: const Offset(1, 2),
//                         )
//                       ],
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: TextField(
//                       controller: controller,
//                       minLines: 1,
//                       maxLines: 5,
//                       textInputAction: TextInputAction.newline,
//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                         hintText: 'Type your message...',
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 GestureDetector(
//                   onTap: () => sendMessage(controller.text),
//                   child: CircleAvatar(
//                     backgroundColor: Colors.blue[800],
//                     radius: 24,
//                     child: const Icon(Icons.send, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DotWidget extends StatelessWidget {
//   const DotWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 8,
//       height: 8,
//       decoration: const BoxDecoration(
//         color: Colors.black45,
//         shape: BoxShape.circle,
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:io'; // Needed for SocketException

class ChatBotScreen extends StatefulWidget {
  final String regno;
  const ChatBotScreen({super.key, required this.regno});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> messages = [];
  TextEditingController controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool showWelcomeMessage = true;
  bool isPersonalGuidance = false;
  bool isLoading = false;
  late AnimationController _animationController;
  late Map<String, dynamic> _resultData = {};
  bool _isLoadingResult = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    setState(() {
      _isLoadingResult = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost/html/get_student_result.php?regno=${widget.regno}'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _resultData = data;
            _courses = List<Map<String, dynamic>>.from(data['courses']);
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch result');
        }
      } else {
        throw Exception(
            'Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoadingResult = false);
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 600), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    });
  }

  // ... your imports

// Inside _ChatBotScreenState
  void sendMessage(String text) async {
    text = text.trim();
    if (text.isEmpty || isLoading) return;

    setState(() {
      messages.add({
        "text": text,
        "isUser": true,
        "timestamp": DateTime.now(),
      });
      showWelcomeMessage = false;
      isLoading = true;
    });

    controller.clear();
    scrollToBottom();

    try {
      Map<String, dynamic> requestBody = {
        'question': text,
        'regno': widget.regno,
      };

      if (isPersonalGuidance) {
        String coursesStr = _courses
            .where((course) => course['grade'] != null)
            .map((course) =>
                '${course['course_code']}:${course['grade']} (Semester ${course['semester']})')
            .join(', ');

        String mergedMessage =
            '$text (I have completed these courses with provided grades. Courses: $coursesStr)';

        requestBody['original_question'] = text;
        requestBody['question'] = mergedMessage;

        List<Map<String, String>> courseGrades = _courses
            .where((course) => course['grade'] != null)
            .map((course) => {
                  'code': course['course_code'].toString(),
                  'grade': course['grade'].toString(),
                  'semester': course['semester'].toString(),
                })
            .toList();

        requestBody['courses'] = courseGrades;
      }

      final response = await http
          .post(
            Uri.parse(
                'http://127.0.0.1:5600/chat'), // Update to real IP if needed
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final reply = responseBody['answer'] ?? 'No answer received';

        setState(() {
          messages.add({
            "text": reply,
            "isUser": false,
            "timestamp": DateTime.now(),
          });
        });
      } else {
        throw HttpException(
            'Server responded with status code ${response.statusCode}');
      }
    } on SocketException {
      _showError("Unable to connect. Server might be down.");
    } on TimeoutException {
      _showError("Please try again and check your internet connection.");
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Unexpected error occurred.");
    } finally {
      setState(() => isLoading = false);
      scrollToBottom();
    }
  }

  void _showError(String message) {
    setState(() {
      messages.add({
        "text": "❗ $message",
        "isUser": false,
        "timestamp": DateTime.now(),
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    final text = msg['text'];
    final isUser = msg['isUser'];
    final timestamp = msg['timestamp'] as DateTime;
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message copied to clipboard'),
            backgroundColor: Colors.blue[800],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.smart_toy, size: 22, color: Colors.blue[800]),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.15,
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blue[800] : Colors.white,
                  boxShadow: [
                    if (!isUser)
                      BoxShadow(
                        color: Colors.blue.shade800,
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 0),
                    bottomRight: Radius.circular(isUser ? 0 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.blue[900],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        timeStr,
                        style: TextStyle(
                          color: isUser ? Colors.white70 : Colors.blue[400],
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isUser)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(Icons.person, size: 22, color: Colors.blue[800]),
              ),
          ],
        ),
      ),
    );
  }

  Widget typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (_, __) => Opacity(
                  opacity: _animationController.value > index * 0.33 ? 1 : 0.3,
                  child: const DotWidget(),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final switchColor = isPersonalGuidance ? Colors.red : Colors.white;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            const SizedBox(width: 8),
            const Text('CuiMate', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          Row(
            children: [
              const Text('Personal Guidance',
                  style: TextStyle(color: Colors.white)),
              Switch(
                value: isPersonalGuidance,
                activeColor: switchColor,
                onChanged: (value) =>
                    setState(() => isPersonalGuidance = value),
              ),
              const SizedBox(width: 10),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isLoading) {
                      return typingIndicator();
                    }
                    return buildMessage(messages[index]);
                  },
                ),
                if (showWelcomeMessage)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 100, color: Colors.blue[800]),
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome to CuiMate!\nHow can I assist you today?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300,
                          blurRadius: 4,
                          offset: const Offset(1, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type your message...',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => sendMessage(controller.text),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue[800],
                    radius: 24,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DotWidget extends StatelessWidget {
  const DotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
    );
  }
}
