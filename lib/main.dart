import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medapp/main_screen.dart';
import 'package:medapp/pages/attendance_page.dart';
import 'package:medapp/pages/events_page.dart';
import 'package:medapp/pages/home_page.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'pages/dashboard_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false, 
      home: AuthWrapper(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/home' : (context) => HomeScreen(),
        '/attendance' : (context) => AttendanceScreen(),
        '/events' : (context) => EventsScreen(),
        '/Main' : (context) => MainScreen(),
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
            return LoginScreen();  // Show login if no user is found
          } else {
            return MainScreen();   // Navigate to the main screen if logged in
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}