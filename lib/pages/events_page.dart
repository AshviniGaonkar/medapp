import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medapp/dbhelper/database_helper.dart';
import 'dart:convert';
import 'package:medapp/pages/mark_attendance.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final String apiUrl = "http://192.168.36.131:5000/events";
  List<Map<String, dynamic>> eventList = [];

  // Controllers for text fields
  TextEditingController nameController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  /// Fetch events from API or load cached data from SQLite
  Future<void> _fetchEvents() async {
    // Load cached events first
    List<Map<String, dynamic>> cachedEvents = await DatabaseHelper.instance.getEvents();
    setState(() {
      eventList = cachedEvents;
    });

    // Fetch new data from server if online
    if (await _isOnline()) {
      try {
        var response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          List<dynamic> events = jsonDecode(response.body);

          // Store new data in SQLite
          for (var event in events) {
            DatabaseHelper.instance.insertEvent({
              "_id": event["_id"],
              "name": event["name"],
              "time": event["time"],
              "location": event["location"],
              "date": event["date"],
              "isSynced": 1, // Mark as synced
            });
          }

          setState(() {
            eventList = events.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      } catch (e) {
        print("⚠️ Error fetching events: $e");
      }
    }
  }

  /// Save event locally first, then sync when online
  Future<void> _saveEvent(String name, String time, String location, String date) async {
    Map<String, dynamic> newEvent = {
      "_id": DateTime.now().toString(), // Temporary ID
      "name": name,
      "time": time,
      "location": location,
      "date": date,
      "isSynced": 0 // Mark as not synced
    };

    // Save event locally in SQLite
    await DatabaseHelper.instance.insertEvent(newEvent);

    setState(() {
      eventList.add(newEvent);
    });

    // Sync if online
    if (await _isOnline()) {
      _syncEventWithServer(newEvent);
    }
  }

  /// Sync event with MongoDB
  Future<void> _syncEventWithServer(Map<String, dynamic> event) async {
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": event["name"],
          "time": event["time"],
          "location": event["location"],
          "date": event["date"],
        }),
      );

      if (response.statusCode == 201) {
        print("✅ Event synced successfully!");

        // Update SQLite data to mark as synced
        await DatabaseHelper.instance.updateEventSyncStatus(event["_id"], true);
      }
    } catch (e) {
      print("❌ Error syncing event: $e");
    }
  }

  /// Check if the device is online
  Future<bool> _isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Show dialog to add an event
  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Event Name")),
              TextField(controller: timeController, decoration: InputDecoration(labelText: "Time")),
              TextField(controller: locationController, decoration: InputDecoration(labelText: "Location")),
              TextField(controller: dateController, decoration: InputDecoration(labelText: "Date (YYYY-MM-DD)"), keyboardType: TextInputType.datetime),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && timeController.text.isNotEmpty && locationController.text.isNotEmpty && dateController.text.isNotEmpty) {
                  _saveEvent(nameController.text, timeController.text, locationController.text, dateController.text);
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
      appBar: AppBar(automaticallyImplyLeading: false, title: Text("Events")),
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
              child: eventList.isEmpty
                  ? Center(child: Text("No Events Yet! Click + to add events."))
                  : ListView.builder(
                      itemCount: eventList.length,
                      itemBuilder: (context, index) {
                        var event = eventList[index];
                        return _eventTile(event["_id"], event["name"], event["time"], event["location"], event["date"]);
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

  /// Event Tile to display each event
  Widget _eventTile(String eventId, String name, String time, String location, String date) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.event, color: Colors.blue),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$time | $location | Date: $date"),
        trailing: Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarkAttendanceScreen(eventId: eventId, eventName: name, eventDate: date),
            ),
          );
        },
      ),
    );
  }
}
