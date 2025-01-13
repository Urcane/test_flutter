import 'package:flutter/material.dart';
import 'package:karunia_test_flutter/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../components/task_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0), // Background color for the whole page
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome, users!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    _logout(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  fillColor: Colors.black,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Today'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Calendar'),
                    ),
                  ],
                  isSelected: [true, false], // Assuming 'Today' is selected
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.add, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Date and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tuesday',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '13.12',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'DEC',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '1:20 PM',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'New York',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '6:20 PM',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'United Kingdom',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Today's Tasks and Reminders Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's tasks",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Reminders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  TaskCard(
                    title: 'You Have A Meeting',
                    startTime: '3:00 PM',
                    endTime: '3:30 PM',
                    duration: 30,
                    backgroundColor: Color(0xFFD9A547),
                    participants: const [
                      'https://t.ly/r7l1U',
                      'https://t.ly/GRHgW',
                    ],
                  ),
                  SizedBox(height: 10),
                  TaskCard(
                    title: 'Call Wiz For Update',
                    startTime: '4:20 PM',
                    endTime: '4:45 PM',
                    duration: 25,
                    backgroundColor: Color(0xFF7A9E9F),
                    participants: const [
                      'https://t.ly/r7l1U',
                      'https://t.ly/GRHgW',
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Logout successful
        await prefs.remove('token');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout successful.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // Logout failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed.')),
        );
      }
    } else {
      // No token found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No token found.')),
      );
    }
  }
}
