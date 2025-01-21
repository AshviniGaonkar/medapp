import 'package:flutter/material.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, String>> _events = [];

  void _addEvent() {
    TextEditingController nameController = TextEditingController();
    TextEditingController timeController = TextEditingController();
    TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Event Name"),
              ),
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: "Time"),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: "Location"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    timeController.text.isNotEmpty &&
                    locationController.text.isNotEmpty) {
                  setState(() {
                    _events.add({
                      "name": nameController.text,
                      "time": timeController.text,
                      "location": locationController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Add Event"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Upcoming Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text("See All")),
              ],
            ),
            Expanded(
              child: _events.isEmpty
                  ? Center(child: Text("No Events Yet! Click + to add events."))
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        return _eventTile(
                          _events[index]["name"]!,
                          _events[index]["time"]!,
                          _events[index]["location"]!,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _actionButton(IconData icon, String text) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          radius: 30,
          child: Icon(icon, color: Colors.blue, size: 30),
        ),
        SizedBox(height: 5),
        Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _eventTile(String name, String time, String location) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.event, color: Colors.blue),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$time | $location"),
        trailing: Icon(Icons.arrow_forward_ios, size: 18),
      ),
    );
  }
}
