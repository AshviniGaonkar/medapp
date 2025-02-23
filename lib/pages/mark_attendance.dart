import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:medapp/dbhelper/database_helper2.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventDate;

  const MarkAttendanceScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.eventDate,
  });

  @override
  MarkAttendanceScreenState createState() => MarkAttendanceScreenState();
}

class MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  Map<String, bool> attendanceStatus = {};
  List<Map<String, dynamic>> students = [];
  bool isAttendanceSubmitted = false;

  final String baseUrl = "https://medapp-djtm.onrender.com";

  @override
  void initState() {
    super.initState();
    _initAttendance();
  }

  Future<void> _initAttendance() async {
    await _checkAttendanceSubmissionStatus();
    await _fetchStudents();
  }

  Future<void> _checkAttendanceSubmissionStatus() async {
    bool submitted =
        await DatabaseHelper2.instance.isAttendanceSubmitted(widget.eventId, widget.eventDate);
    if (mounted) {
      setState(() => isAttendanceSubmitted = submitted);
    }
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/students"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        students = data.map((student) => {
          "id": student["_id"],
          "name": student["name"],
        }).toList();

        for (var student in students) {
          await DatabaseHelper2.instance.insertStudent(student);
        }
      } else {
        throw Exception("Failed to fetch students");
      }
    } catch (e) {
      log("Error fetching students: $e");
      students = await DatabaseHelper2.instance.getStudentsForEvent(widget.eventId);
    }

    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    var storedAttendance =
        await DatabaseHelper2.instance.getAttendance(widget.eventId, widget.eventDate);
    if (storedAttendance.isNotEmpty && mounted) {
      setState(() {
        for (var attendance in storedAttendance) {
          attendanceStatus[attendance['id']] = attendance['present'] == 1;
        }
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (isAttendanceSubmitted) return;

    final url = Uri.parse("$baseUrl/attendance/submit");

    List<Map<String, dynamic>> attendanceList = attendanceStatus.entries.map((entry) => {
      "studentId": entry.key,
      "present": entry.value,
      "eventDate": widget.eventDate,
    }).toList();

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "eventId": widget.eventId,
          "attendanceData": attendanceList,
        }),
      );

      if (response.statusCode == 200) {
        log("Attendance submitted successfully!");

        if (mounted) {
          setState(() => isAttendanceSubmitted = true);
          await DatabaseHelper2.instance.markAttendanceAsSubmitted(widget.eventId, widget.eventDate);

          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Attendance Submitted")));
          Navigator.pop(context, true); // Pop with success status
        }
      } else {
        throw Exception("Failed to submit attendance");
      }
    } catch (e) {
      log("Error submitting attendance: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error submitting attendance")));
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = attendanceStatus.values.where((status) => status).length;
    int absentCount = students.length - presentCount;

    return Scaffold(
      appBar: AppBar(
          title: Text("Mark Attendance - \${widget.eventName}"),
          backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statusBox("$presentCount", "Present", Colors.green),
                const SizedBox(width: 20),
                _statusBox("$absentCount", "Absent", Colors.red),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildStudentList()),
            if (!isAttendanceSubmitted)
              ElevatedButton(
                onPressed: _submitAttendance,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                child: const Text("Submit Attendance"),
              )
            else
              const Text("Attendance Already Submitted", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        var student = students[index];
        return CheckboxListTile(
          title: Text(student['name']),
          value: attendanceStatus[student['id']] ?? false,
          onChanged: (bool? value) {
            if (!isAttendanceSubmitted) {
              setState(() {
                attendanceStatus[student['id']] = value ?? false;
              });
            }
          },
        );
      },
    );
  }

  Widget _statusBox(String count, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
