import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  MarkAttendanceScreen({required this.eventId, required this.eventName});

  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection("students");

  final CollectionReference attendanceCollection =
      FirebaseFirestore.instance.collection("events");

  Map<String, bool> attendanceStatus = {}; // Stores students' attendance status

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    QuerySnapshot attendanceSnapshot = await attendanceCollection
        .doc(widget.eventId)
        .collection("attendance")
        .get();

    Map<String, bool> tempStatus = {};
    for (var doc in attendanceSnapshot.docs) {
      tempStatus[doc.id] = doc["present"];
    }

    setState(() {
      attendanceStatus = tempStatus;
    });
  }

  void _toggleAttendance(String studentId, bool isPresent) async {
    await attendanceCollection
        .doc(widget.eventId)
        .collection("attendance")
        .doc(studentId)
        .set({"present": isPresent});

    setState(() {
      attendanceStatus[studentId] = isPresent;
    });
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = attendanceStatus.values.where((status) => status).length;
    int absentCount = attendanceStatus.length - presentCount;

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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: studentsCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No students available."));
                  }

                  var studentDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: studentDocs.length,
                    itemBuilder: (context, index) {
                      var student = studentDocs[index];
                      String studentId = student.id;
                      String studentName = student["name"];
                      bool isPresent = attendanceStatus[studentId] ?? false;

                      return _studentAttendanceTile(studentName, index + 1, isPresent, studentId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
          onChanged: (bool? newValue) {
            _toggleAttendance(studentId, newValue ?? false);
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
