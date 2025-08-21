import 'package:flutter/material.dart';
import '../main.dart';
import 'chatbot.dart';

AppBar buildStudentProfileAppBar(BuildContext context, String title, String regno) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(
        color: Colors.white, // Adjust color as needed
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: Colors.blue.shade800, // Adjust background color as needed
    elevation: 1, // Subtle shadow
    // Removed leading (back button)
    actions: [
      IconButton(
        icon: Icon(Icons.chat, color: Colors.white), // Chat icon
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => ChatBotScreen(regno: regno,)));

          // Navigate to chat screen
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ChatScreen()),
          // );
        },
      ),
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: Colors.white), // Three dots
        onSelected: (value) {
          if (value == 'logout') {
            // Handle logout
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Logout'),
                content: Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Perform logout
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.black54),
                SizedBox(width: 8),
                Text('Logout'),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
