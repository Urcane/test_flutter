import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:karunia_test_flutter/pages/home_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  Future<void> register() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'confirm_password': confirmPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      showResponseMessage(response.body, context);
    }
  }

  void showResponseMessage(String responseBody, BuildContext context) {
    final data = jsonDecode(responseBody);
    final bool success = data['success'];
    final String message = data['message'];
    final Map<String, dynamic> errorData = data['data'] ?? {};

    List<String> errorMessages = [];

    if (!success) {
      errorMessages.add(message);

      errorData.forEach((key, value) {
        if (value is List) {
          for (var error in value) {
            errorMessages.add(error);
          }
        }
      });

      for (var errorMessage in errorMessages) {
        Future.delayed(const Duration(milliseconds: 200), () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/urcane_logo.png', // Update with your logo
                height: 100,
              ),
              const SizedBox(height: 10),
              const Text(
                'Catch all of your ideas!',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Name TextField
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your name',
                  labelStyle: const TextStyle(
                    fontSize: 12,
                  ),
                  hintText: 'Enter your name',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

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

              // Confirm Password TextField
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm your password',
                  labelStyle: const TextStyle(
                    fontSize: 12,
                  ),
                  hintText: 'Re-enter your password',
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
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.grey[300],
                ),
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Already have an account? Login'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
