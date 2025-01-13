import 'package:flutter/material.dart';
import 'package:karunia_test_flutter/auth/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/auth/login_page.dart'; // Import the LoginPage
import '/pages/home_page.dart'; // Import the HomePage
import 'package:http/http.dart' as http;


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // Validate the token
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/auth'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Token is valid, navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Token is invalid, navigate to LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Welcome()),
        );
      }
    } else {
      // No token, navigate to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}