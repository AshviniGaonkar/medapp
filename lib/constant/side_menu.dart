import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medapp/constants.dart';

class SideMenu extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });
  

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  User? user = FirebaseAuth.instance.currentUser;
  String facultyName = "";
  String facultyEmail = "";

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
            facultyEmail = doc["email"];
          });
        } else {
          setState(() {
            facultyName = "Unknown Faculty";
            facultyEmail = "No email found";
          });
        }
      } catch (e) {
        setState(() {
          facultyName = "Avishkar";
          facultyEmail = "gadadeavishkar98@gmail.com";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
  
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: constc
            ),
            accountName: Text(facultyName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),),
            accountEmail: Text(facultyEmail,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),
          ),
          _drawerItem(
            context,
            icon: Icons.home,
            text: "Home",
            index: 0,
          ),
          _drawerItem(
            context,
            icon: Icons.event,
            text: "Events",
            index: 1,
          ),
          _drawerItem(
            context,
            icon: Icons.man_3_rounded,
            text: "Attendance",
            index: 2,
          ),
          _drawerItem(context, icon: Icons.dashboard, text: "Dashboard", index: 3),
          Divider(),
          _drawerItem(
            context,
            icon: Icons.logout,
            text: "Logout",
            index: -1, // Special index for logout
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context,
      {required IconData icon, required String text, required int index}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text, style: TextStyle(fontSize: 18)),
      selected: widget.selectedIndex == index,
      selectedTileColor: Colors.grey.shade300,
      onTap: () {
        if (index == -1) {
          _logout(context); // Call logout function
        } else {
          widget.onTabChange(index);
          Navigator.pop(context); // Close the drawer
        }
      },
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase logout
      Navigator.pop(context); // Close the drawer
      Navigator.pushReplacementNamed(context, "/login"); // Navigate to login page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${e.toString()}")),
      );
    }
  }
}
