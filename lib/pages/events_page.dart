import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medapp/dbhelper/database_helper.dart';
import 'package:medapp/pages/mark_attendance.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  EventsScreenState createState() => EventsScreenState();
}

class EventsScreenState extends State<EventsScreen> {
  final String apiUrl = "https://medapp-djtm.onrender.com/events";
  List<Map<String, dynamic>> eventList = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      List<Map<String, dynamic>> cachedEvents = await DatabaseHelper.instance.getEvents();
      List<Map<String, dynamic>> filteredEvents = [];

      for (var event in cachedEvents) {
        bool isSubmitted = await _checkAttendance(event["_id"], event["date"]);
        if (!isSubmitted) {
          filteredEvents.add(event);
        }
      }

      setState(() {
        eventList = filteredEvents;
      });

      if (await _isOnline()) {
        var response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          List<dynamic> events = jsonDecode(response.body);

          for (var event in events) {
            bool exists = await DatabaseHelper.instance.eventExists(event["_id"]);
            if (!exists) {
              await DatabaseHelper.instance.insertEvent({
                "_id": event["_id"],
                "name": event["name"],
                "time": event["time"],
                "location": event["location"],
                "date": event["date"],
                "isSynced": 1,
              });
            }
          }
          await _updateEventList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching events: $e");
    }
  }

  Future<void> _updateEventList() async {
    List<Map<String, dynamic>> updatedEvents = await DatabaseHelper.instance.getEvents();
    List<Map<String, dynamic>> filteredEvents = [];

    for (var event in updatedEvents) {
      bool isSubmitted = await _checkAttendance(event["_id"], event["date"]);
      if (!isSubmitted) {
        filteredEvents.add(event);
      }
    }

    setState(() {
      eventList = filteredEvents;
    });
  }

  Future<bool> _isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }

  Future<bool> _checkAttendance(String eventId, String date) async {
    return await DatabaseHelper.instance.isAttendanceSubmitted(eventId, date);
  }

  void _navigateToMarkAttendance(String eventId, String name, String date) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarkAttendanceScreen(
          eventId: eventId,
          eventName: name,
          eventDate: date,
        ),
      ),
    );
    _updateEventList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events")),
      body: eventList.isEmpty
          ? const Center(child: Text("No Events Available."))
          : ListView.builder(
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                var event = eventList[index];
                return _eventTile(event);
              },
            ),
    );
  }

  Widget _eventTile(Map<String, dynamic> event) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.event, color: Colors.blue),
        title: Text(
          event["name"] ?? "Unknown Event",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            "${event["location"] ?? "No location"} | ${event["time"] ?? "No time"} | Date: ${event["date"] ?? "Unknown date"}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () => _navigateToMarkAttendance(
          event["_id"],
          event["name"],
          event["date"],
        ),
      ),
    );
  }
}
