import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_flutter/pages/home_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/pages/profile_page.dart';
import 'register_page.dart'; // Import the RegisterPage

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
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('https://demo.urproj.com/api/auth'),   
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          // Token is invalid, clear the token and show login page
          await prefs.remove('token');
        }
      }
    } catch (e, st) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed.')),
      );
      if (kDebugMode) {
        print("$e");
        print("$st");
      }
    }
  }

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.urproj.com/api/login'),
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
          Uri.parse('https://demo.urproj.com/api/auth'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (authResponse.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
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
    } catch (e, st) {
      if (kDebugMode) {
        print("$e");
        print("$st");
      }
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
              const SizedBox(height: 50),
              Image.asset(
                'assets/images/LOGO-website.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Catch all of your ideas!',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
        
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
              const SizedBox(height: 20),
        
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async { 
                  await login();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
              const SizedBox(height: 20),
        
              // Divider Text
              const Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("or"),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),
        
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.white,
                  overlayColor: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
        
              // Apple Sign-up Button
              ElevatedButton.icon(
                onPressed: () {
                  // Handle Apple Sign-In
                },
                icon: const Icon(
                  Icons.apple,
                  size: 24,
                ),
                label: const Text('Sign up with Apple'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
