import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Function to handle user sign-up
  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid; // Get UID of the faculty

      // Store faculty details in Firestore
      await FirebaseFirestore.instance.collection('faculty').doc(uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'created_at': FieldValue.serverTimestamp(), // Stores current timestamp
      });

      // Navigate to Login Screen
      Navigator.pushReplacementNamed(context, "/login");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-up successful! Please login.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Faculty Sign Up")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Name Field
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your full name.";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email.";
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return "Please enter a valid email.";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password.";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters.";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password.";
                      }
                      if (value != passwordController.text) {
                        return "Passwords do not match.";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Sign-Up Button
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: signUp,
                          child: Text("Sign Up"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                  SizedBox(height: 10),

                  // Already have an account? Login button
                  TextButton(
                    onPressed: () {
                      // Navigate before setting loading state
                      Navigator.pushReplacementNamed(context, "/login");

                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: Text("Already have an account? Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
