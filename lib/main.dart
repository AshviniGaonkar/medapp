import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medapp/Welcome/components/students_login_screen.dart';
import 'package:medapp/Welcome/welcome_screen.dart';
import 'package:medapp/main_screen.dart';
import 'package:medapp/pages/attendance_page.dart';
import 'package:medapp/pages/events_page.dart';
import 'package:medapp/pages/home_page.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'pages/dashboard_screen.dart';

// Constants for styling
const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);
const defaultPadding = 16.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: kPrimaryColor,
            shape: const StadiumBorder(),
            maximumSize: const Size(double.infinity, 56),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: kPrimaryLightColor,
          iconColor: kPrimaryColor,
          prefixIconColor: kPrimaryColor,
          contentPadding: EdgeInsets.symmetric(
              horizontal: defaultPadding, vertical: defaultPadding),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: AuthWrapper(),
      initialRoute: '/welcome',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/home': (context) => HomeScreen(),
        '/attendance': (context) => AttendanceScreen(),
        '/events': (context) => EventsScreen(),
        '/Main': (context) => MainScreen(),
        '/welcome': (context) => WelcomeScreen(),
        "/student_login": (context) => StudentLoginScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return LoginScreen(); // Show login if no user is found
          } else {
            return MainScreen(); // Navigate to the main screen if logged in
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
