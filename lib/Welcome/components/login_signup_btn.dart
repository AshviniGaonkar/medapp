import 'package:flutter/material.dart';

class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/login");
          },
          child: Text("Login as Faculty"),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/student_login");
          },
          child: Text("Login as Student"),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
