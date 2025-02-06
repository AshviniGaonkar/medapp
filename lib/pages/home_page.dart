import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
        title: Text("Today's Classes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimationLimiter(
          child: ListView(
            children: [
              _buildClassTile("DBMS", "Sem-4 CSBS", 32, "09:35 - 10:30 AM"),
              _buildClassTile("Operating System", "Sem-4 CSBS", 36, "10:40 - 11:35 AM"),
              _buildBreakTile("11:35 AM - 12:00 PM"),
              _buildClassTile("DSA", "SEM-5 CSBS", 32, "12:00 - 01:00 PM"),
              _buildClassTile("Computer Networks", "Sem-5 CSBS", 55, "01:00 PM - 3:00 PM"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassTile(String title, String className, int students, String time) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 350),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 8,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              subtitle: Text("No of Students: $students | Class: $className", style: TextStyle(color: Colors.grey[600])),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(time, style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakTile(String time) {
    return AnimationConfiguration.staggeredList(
      position: 1,
      duration: const Duration(milliseconds: 350),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            color: Colors.grey[200],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(Icons.local_cafe, color: Colors.brown),
              title: Text("Break Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              subtitle: Text(time, style: TextStyle(color: Colors.grey[600])),
            ),
          ),
        ),
      ),
    );
  }
}
