import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String facultyName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchFacultyDetails();
  }

  Future<void> _fetchFacultyDetails() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("faculty")
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        setState(() {
          facultyName = doc["name"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome, Prof. $facultyName ",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
