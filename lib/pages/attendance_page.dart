import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(

      child: Text("GPS Attendance"),
    );
  }
}