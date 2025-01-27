import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        
        title: Text("My Classes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _classTile("DBMS", "Sem-4 CSBS", 32, "09:35 - 10:30 AM"),
            _classTile("Operating System", "Sem-4 CSBS", 36, "10:40 - 11:35 AM"),
            _breakTile("11:35 AM - 12:00 PM"),
            _classTile("DSA", "SEM-5 CSBS", 32, "12:00 - 01:00 PM"),
            _classTile("Computer Networks", "Sem-5 CSBS", 55, "01:00 PM - 3:00 PM"),
          ],
        ),
      ),
    );
  }

  Widget _classTile(String title, String className, int students, String time) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("No of Students: $students | Class: $className"),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(time, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _breakTile(String time) {
    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.local_cafe, color: Colors.brown),
        title: Text("Break Time"),
        subtitle: Text(time),
      ),
    );
  }
}
