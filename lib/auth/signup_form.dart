import 'package:flutter/material.dart';

class SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onSignUp;

  const SignUpForm({super.key, 
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
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
              if (value == null || value.isEmpty) return "Enter your email.";
              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(value)) {
                return "Enter a valid email.";
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
                return "Enter a password.";
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
              if (value == null || value.isEmpty) return "Confirm your password.";
              if (value != passwordController.text) return "Passwords do not match.";
              return null;
            },
          ),
          SizedBox(height: 20),

          // Sign-Up Button
          isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: onSignUp,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text("Sign Up"),
                ),
          SizedBox(height: 10),

          // Already have an account? Login button
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
            child: Text("Already have an account? Login"),
          ),
        ],
      ),
    );
  }
}
