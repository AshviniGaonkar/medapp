import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medapp/pages/mark_attendance.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection("events");

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
                  _saveEventToFirestore(
                    nameController.text,
                    timeController.text,
                    locationController.text,
                  );
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

Future<void> _saveEventToFirestore(String name, String time, String location) async {
  try {
    await eventsCollection.add({
      "name": name,
      "time": time,
      "location": location,
      "createdAt": FieldValue.serverTimestamp(),
    });
    print("Event added successfully!");
  } catch (e) {
    print("Error adding event: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              child: StreamBuilder<QuerySnapshot>(
                stream: eventsCollection.orderBy("createdAt", descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No Events Yet! Click + to add events."));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var event = snapshot.data!.docs[index];
                      return _eventTile(
                        event.id,
                        event["name"],
                        event["time"],
                        event["location"],
                      );
                    },
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
  Widget _eventTile(String eventId, String name, String time, String location) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: ListTile(
      leading: Icon(Icons.event, color: Colors.blue),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("$time | $location"),
      trailing: Icon(Icons.arrow_forward_ios, size: 18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarkAttendanceScreen(eventId: eventId, eventName: name),
          ),
        );
      },
    ),
  );
}


}
