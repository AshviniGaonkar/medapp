import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medapp/constant/bottom_nav_bar.dart';
import 'package:medapp/constant/side_menu.dart';
import 'package:medapp/constants.dart';
import 'package:medapp/pages/attendance_page.dart';
import 'package:medapp/pages/dashboard_screen.dart';
import 'package:medapp/pages/events_page.dart';
import 'package:medapp/pages/home_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;
  String facultyName = "Loading...";

  final List<Widget> _pages = [
    HomeScreen(),
    EventsScreen(),
    AttendanceScreen(),
    DashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchFacultyDetails();
  }

  // Fetch faculty details from Firestore
  Future<void> _fetchFacultyDetails() async {
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection("faculty")
            .doc(user!.uid)
            .get();

        if (doc.exists) {
          setState(() {
            facultyName = doc["name"];
          });
        }
      } catch (e) {
        setState(() {
          facultyName = "Error loading name";
        });
      }
    }
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constc,
        shadowColor: Colors.black,
        title: Text(
          "Smart Systems",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ),
      drawer: SideMenu(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
