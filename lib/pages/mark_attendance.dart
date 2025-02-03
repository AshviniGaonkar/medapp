import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventDate;

  MarkAttendanceScreen({required this.eventId, required this.eventName, required this.eventDate});

  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  late Box attendanceBox;
  late Box studentBox;

  Map<String, bool> attendanceStatus = {};
  List<Map<String, dynamic>> students = [];
  bool isAttendanceSubmitted = false;


final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  // Initialize Hive and open required boxes
  Future<void> _initHive() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
    attendanceBox = await Hive.openBox('attendance');
    studentBox = await Hive.openBox('students');

    await _fetchStudents();
    _loadAttendance();
  }

  // Fetch students from API and save to Hive for offline access
  Future<void> _fetchStudents() async {
    final url = Uri.parse("$baseUrl/students");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          students = data.cast<Map<String, dynamic>>();
        });

        // Store students in Hive
        studentBox.put("students_data", students);
      }
    } catch (e) {
      print("⚠️ Error fetching students: $e");

      // Load students from Hive if API request fails (offline mode)
      var storedStudents = studentBox.get("students_data");
      if (storedStudents != null) {
        setState(() {
          students = List<Map<String, dynamic>>.from(storedStudents);
        });
      }
    }
  }

  // Load attendance data from Hive
  void _loadAttendance() {
    String eventKey = "attendance_${widget.eventId}";
    var storedData = attendanceBox.get(eventKey);

    if (storedData != null) {
      setState(() {
        attendanceStatus = Map<String, bool>.from(storedData['attendanceData']);
        isAttendanceSubmitted = storedData['submitted'];
      });
    }
  }

  // Save attendance locally for offline use
  void _saveAttendanceLocally() {
    String eventKey = "attendance_${widget.eventId}";
    attendanceBox.put(eventKey, {
      "attendanceData": attendanceStatus,
      "submitted": isAttendanceSubmitted,
    });
  }

  // Submit attendance to server and save locally
  Future<void> _submitAttendance() async {
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
        body: json.encode({"eventId": widget.eventId, "attendanceData": attendanceList}),
      );

      if (response.statusCode == 200) {
        print("✅ Attendance submitted successfully!");
        setState(() {
          isAttendanceSubmitted = true;
        });

        _saveAttendanceLocally(); // Save attendance in Hive

        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      print("❌ Error submitting attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = attendanceStatus.values.where((status) => status).length;
    int absentCount = students.length - presentCount;

    return Scaffold(
      appBar: AppBar(title: Text("Mark Attendance - ${widget.eventName}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            if (!isAttendanceSubmitted)
              ElevatedButton(
                onPressed: _submitAttendance,
                child: Text("Submit Attendance"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue,
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (students.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        var student = students[index];
        String studentId = student["_id"];
        String studentName = student["name"];
        bool isPresent = attendanceStatus[studentId] ?? false;

        return _studentAttendanceTile(studentName, index + 1, isPresent, studentId);
      },
    );
  }

  Widget _statusBox(String count, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          child: Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _studentAttendanceTile(String name, int rollNo, bool isPresent, String studentId) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Checkbox(
          value: isPresent,
          onChanged: isAttendanceSubmitted ? null : (bool? newValue) {
            setState(() {
              attendanceStatus[studentId] = newValue ?? false;
              _saveAttendanceLocally(); // Save instantly on change
            });
          },
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Roll No: $rollNo"),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isPresent ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(isPresent ? "Present" : "Absent", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
