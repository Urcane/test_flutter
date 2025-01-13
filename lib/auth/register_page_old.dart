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

      // Navigate to another page or display a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Handle errors
      
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
        // Wrap the Column with SingleChildScrollView to make it scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make sure children use the full width
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to login page
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true, // Adjust the size when the keyboard appears
    );
  }
}