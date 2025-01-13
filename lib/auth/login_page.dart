import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:karunia_test_flutter/pages/home_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart'; // Import the RegisterPage
import '/pages/home_page.dart'; // Import the HomePage
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/auth'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Token is invalid, clear the token and show login page
        await prefs.remove('token');
      }
    }
  }

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // Validate the token
      final authResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/auth'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (authResponse.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid token after login.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/urcane_logo.png',
                height: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Catch all of your ideas!',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
        
              // Email TextField
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Your email address',
                  labelStyle: const TextStyle(
                    fontSize: 12,
                  ),
                  hintText: 'Enter your email',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
        
              // Password TextField
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Choose a password',
                  labelStyle: const TextStyle(
                    fontSize: 12,
                  ),
                  hintText: 'min. 8 characters',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: const Icon(Icons.visibility_off),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.grey[300], // Change to desired color
                ),
                child: const Text('Continue'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text('create an account'),
              ),
              SizedBox(height: 20),
        
              // Divider Text
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("or"),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              SizedBox(height: 20),
        
              // Google Sign-up Button
              ElevatedButton.icon(
                onPressed: () {
                  // Handle Google Sign-In
                },
                icon: Image.asset(
                  'assets/images/google_logo.png', // Replace with your asset path
                  height: 24,
                  width: 24,
                ),
                label: const Text('Sign up with Google'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.white,
                  overlayColor: Colors.black,
                ),
              ),
              SizedBox(height: 10),
        
              // Apple Sign-up Button
              ElevatedButton.icon(
                onPressed: () {
                  // Handle Apple Sign-In
                },
                icon: Icon(
                  Icons.apple,
                  size: 24,
                ),
                label: const Text('Sign up with Apple'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.black,
                  overlayColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
