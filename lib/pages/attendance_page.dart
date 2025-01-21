import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Map<String, bool> attendance = {
    "Akash Gupta": true,
    "Brijesh Gupta": false,
    "Cajeton D'souza": true,
    "Danish Shaikh": true,
    "Daniel Walter": true,
    "Faisal Khan": true,
  };

  @override
  Widget build(BuildContext context) {
    int presentCount = attendance.values.where((status) => status).length;
    int absentCount = attendance.length - presentCount;

    return Scaffold(
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
              child: ListView.builder(
                itemCount: attendance.length,
                itemBuilder: (context, index) {
                  String name = attendance.keys.elementAt(index);
                  bool isPresent = attendance[name] ?? true;
                  return _studentAttendanceTile(name, index + 1, isPresent);
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 14),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {},
              child: Text("Confirm & Submit Attendance", style: TextStyle(fontSize: 18, color: Colors.white)),
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


  Widget _studentAttendanceTile(String name, int rollNo, bool isPresent) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Checkbox(
          value: isPresent,
          onChanged: (bool? newValue) {
            setState(() {
              attendance[name] = newValue ?? true;
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
