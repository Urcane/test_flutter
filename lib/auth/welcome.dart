import 'package:flutter/material.dart';
import 'package:karunia_test_flutter/auth/login_page.dart';
import 'package:karunia_test_flutter/auth/register_page.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Image.asset(
                'assets/images/login_page.png', // Add your image to assets and reference here
                height: 250, // Adjust as needed
              ),
            ),
            const SizedBox(height: 70),
            const Text(
              'Access your world of mind!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            const Text(
              'Catch the moment every detail with RecogNotes.\n Record conversations, lectures, meetings, and more, and watch as they are transcribed into accurate text instantly.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 161, 67, 205),
                    padding: const EdgeInsets.symmetric(horizontal: 92, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Login', 
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 161, 67, 205),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color.fromARGB(255, 161, 67, 205)),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
