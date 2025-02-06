import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medapp/constants.dart';
import 'package:medapp/dbhelper/database_helper.dart';
import 'dart:convert';
import 'package:medapp/pages/mark_attendance.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final String apiUrl = "https://medapp-na6j.onrender.com:5000/events";
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
          // Store new data in SQLite if not already present
for (var event in events) {
  bool exists = await DatabaseHelper.instance.eventExists(event["_id"]);
  if (!exists) {
    await DatabaseHelper.instance.insertEvent({
      "_id": event["_id"],
      "name": event["name"],
      "time": event["time"],
      "location": event["location"],
      "date": event["date"],
      "isSynced": 1, // Mark as synced
    });
  }
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

  Future<void> _saveEvent(String name, String time, String location, String date) async {
  String eventId = DateTime.now().toString();

  bool exists = await DatabaseHelper.instance.eventExists(eventId);
  if (exists) return; // Prevent duplicate insertion

  Map<String, dynamic> newEvent = {
    "_id": eventId,
    "name": name,
    "time": time,
    "location": location,
    "date": date,
    "isSynced": 0
  };
  await DatabaseHelper.instance.insertEvent(newEvent);
  setState(() {
    eventList.add(newEvent);
  });

  if (await _isOnline()) {
    _syncEventWithServer(newEvent);
  }
}


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
        print(" Event synced successfully!");
        await DatabaseHelper.instance.updateEventSyncStatus(event["_id"], true);
      }
    } catch (e) {
      print(" Error syncing event: $e");
    }
  }

  Future<bool> _isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Event",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Event Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: "Time",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: "Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime initialDate = DateTime.now();
                      DateTime firstDate = DateTime.now(); // Disable past dates
                      DateTime lastDate = DateTime(2101);
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: firstDate,
                        lastDate: lastDate,
                      );
                      if (picked != null && picked != initialDate) {
                        setState(() {
                          dateController.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    timeController.text.isNotEmpty &&
                    locationController.text.isNotEmpty &&
                    dateController.text.isNotEmpty) {
                  _saveEvent(nameController.text, timeController.text,
                      locationController.text, dateController.text);
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
        backgroundColor: constc,
      ),
    );
  }

  Widget _eventTile(String eventId, String name, String time, String location,
      String date) {
    return Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(Icons.event, color: constc),
          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("$location | $time |           Date: $date"),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarkAttendanceScreen(
                    eventId: eventId, eventName: name, eventDate: date),
              ),
            );
          },
        ),
      );
  }
}
