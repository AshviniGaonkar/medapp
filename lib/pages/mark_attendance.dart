import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medapp/dbhelper/database_helper2.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventDate;

  MarkAttendanceScreen({required this.eventId, required this.eventName, required this.eventDate});

  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  Map<String, bool> attendanceStatus = {}; // Stores student ID & presence status
  List<Map<String, dynamic>> students = []; // Stores student list
  bool isAttendanceSubmitted = false; // Tracks if attendance was submitted

  final String baseUrl = "http://44.226.145.213:5000"; // Update with your API IP

  @override
  void initState() {
    super.initState();
    _checkAttendanceSubmissionStatus(); // Check if attendance is already submitted
    _fetchStudents(); // Load students & attendance when screen opens
  }

  //  Check if attendance has already been submitted
  Future<void> _checkAttendanceSubmissionStatus() async {
    bool submitted = await DatabaseHelper2.instance.isAttendanceSubmitted(widget.eventId, widget.eventDate);
    setState(() {
      isAttendanceSubmitted = submitted;
    });
  }

  //  Fetch students from API or SQLite (if offline)
  // Fetch students from API or SQLite (if offline)
Future<void> _fetchStudents() async {
  final url = Uri.parse("$baseUrl/students");
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        students = data.map((student) => {
          "id": student["_id"],
          "name": student["name"],
        }).toList();
      });

      // Store students in SQLite for offline access
      for (var student in students) {
        await DatabaseHelper2.instance.insertStudent({
          "id": student["id"],
          "name": student["name"],
        });
      }
    } else {
      throw Exception("Failed to fetch students");
    }
  } catch (e) {
    print("Error fetching students: $e");

    // Load students from SQLite using eventId
    var storedStudents = await DatabaseHelper2.instance.getStudentsForEvent(widget.eventId);
    setState(() {
      students = storedStudents;
    });
  }

  _loadAttendance(); // Load saved attendance data
}


  //  Load saved attendance from SQLite
  void _loadAttendance() async {
    var storedAttendance = await DatabaseHelper2.instance.getAttendance(widget.eventId, widget.eventDate);
    if (storedAttendance.isNotEmpty) {
      setState(() {
        for (var attendance in storedAttendance) {
          if (attendance['id'] != null) {
            attendanceStatus[attendance['id']] = attendance['present'] == 1;
          }
        }
      });
    }
  }

  //  Save attendance locally in SQLite
  void _saveAttendanceLocally({required bool isSynced}) async {
    for (var studentId in attendanceStatus.keys) {
      await DatabaseHelper2.instance.insertAttendance({
        "id": studentId,
        "eventId": widget.eventId,
        "eventDate": widget.eventDate,
        "present": attendanceStatus[studentId]! ? 1 : 0,
        "isSynced": isSynced ? 1 : 0,
        "isSubmitted": isAttendanceSubmitted ? 1 : 0, // Include submission status
      });
    }
  }

  //  Submit attendance to the server
  Future<void> _submitAttendance() async {
    if (isAttendanceSubmitted) {
      print("Attendance already submitted!");
      return;
    }

    final url = Uri.parse("$baseUrl/attendance/submit");

    List<Map<String, dynamic>> attendanceList = attendanceStatus.entries.map((entry) {
      return {
        "studentId": entry.key,
        "present": entry.value,
        "eventDate": widget.eventDate,
      };
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
        print(" Attendance submitted successfully!");
        setState(() {
          isAttendanceSubmitted = true;
        });

        // Mark attendance as submitted in the local database
        await DatabaseHelper2.instance.markAttendanceAsSubmitted(widget.eventId, widget.eventDate);

        // Save attendance locally with isSubmitted = true
        _saveAttendanceLocally(isSynced: true);

        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      print(" Error submitting attendance: $e");
      _saveAttendanceLocally(isSynced: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = attendanceStatus.values.where((status) => status).length;
    int absentCount = students.length - presentCount;

    return Scaffold(
      appBar: AppBar(title: Text("Mark Attendance - ${widget.eventName}"), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status row with colorful boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statusBox("$presentCount", "Present", Colors.green),
                SizedBox(width: 20),
                _statusBox("$absentCount", "Absent", Colors.red),
              ],
            ),
            SizedBox(height: 10),
            Expanded(child: _buildStudentList()),

            // Show a message if attendance is already submitted
            if (isAttendanceSubmitted)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Attendance Submitted",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),

            // Hide submit button if attendance is already submitted
            if (!isAttendanceSubmitted)
              ElevatedButton(
                onPressed: _submitAttendance,
                child: Text("Submit Attendance"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurpleAccent,
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // A widget for displaying the status boxes (Present/Absent count)
  Widget _statusBox(String count, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), spreadRadius: 2, blurRadius: 5)],
          ),
          child: Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // Building student list with dynamic presence status
  Widget _buildStudentList() {
    if (students.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        var student = students[index];
        String studentId = student["id"] ?? "";
        String studentName = student["name"] ?? "Unknown Student";
        bool isPresent = attendanceStatus[studentId] ?? false;

        return _studentAttendanceTile(studentName, index + 1, isPresent, studentId);
      },
    );
  }

  // A widget for displaying the student attendance tile
  Widget _studentAttendanceTile(String name, int rollNo, bool isPresent, String studentId) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(
          isPresent ? Icons.check_circle : Icons.cancel,
          color: isPresent ? Colors.green : Colors.red,
          size: 28,
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text("Roll No: $rollNo", style: TextStyle(fontSize: 14)),

        trailing: Checkbox(
          value: attendanceStatus[studentId] ?? false,
          onChanged: isAttendanceSubmitted
              ? null // Disable checkbox if attendance is already submitted
              : (bool? newValue) {
                  setState(() {
                    attendanceStatus[studentId] = newValue ?? false;
                  });
                  _saveAttendanceLocally(isSynced: false);
                },
        ),
      ),
    );
  }
}
