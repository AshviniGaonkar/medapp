require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
app.use(cors()); // Allow all origins for development
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url} - Body:`, req.body);
  next();
});

// 🔹 Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => console.log("✅ MongoDB Connected"))
  .catch(err => console.error("❌ MongoDB Connection Error:", err));

// 🔹 Event Schema (updated without dateConstraints)
const eventSchema = new mongoose.Schema({
  name: { type: String, required: true },
  location: { type: String, required: true },
  time: { type: String, required: true }, // Time in "HH:mm" format
  date: { type: Date, required: true },
});

const studentSchema = new mongoose.Schema({
  name: { type: String, required: true },
  rollNo: { type: String, required: true, unique: true }
});

const attendanceSchema = new mongoose.Schema({
  studentId: { type: String, required: true },
  eventId: { type: String, required: true },
  eventDate: { type: String, required: true },
  present: { type: Boolean, required: true }
});

// Define models
const Event = mongoose.model("Event", eventSchema);
const Student = mongoose.model("Student", studentSchema);
const Attendance = mongoose.model("Attendance", attendanceSchema);

// 🟢 **Create Event** 
app.post('/events', async (req, res) => {
  try {
    const { name, location, time, date } = req.body;
    
    // Check if the required fields are present
    if (!name || !location || !time || !date) {
      return res.status(400).json({ message: "All fields are required: name, location, time, date." });
    }

    // Create a new event
    const event = new Event({
      name,
      location,
      time,
      date
    });

    // Save the event to the database
    await event.save();

    // Return the saved event
    res.status(201).json(event);
  } catch (error) {
    console.error("❌ Error creating event:", error);
    res.status(500).json({ message: "Failed to create event." });
  }
});

// 🟢 **Get All Events**
app.get("/events", async (req, res) => {
  try {
    const events = await Event.find();
    res.json(events);  
  } catch (err) {
    console.error("❌ Error fetching events:", err);
    res.status(500).json({ message: "Failed to fetch events" });
  }
});


// 🟢 **Get All Students**
app.get("/students", async (req, res) => {
  try {
    const students = await Student.find();
    console.log("✅ Students fetched:", students);
    res.json(students);
  } catch (err) {
    console.error("❌ Error fetching students:", err);
    res.status(500).json({ error: "Failed to fetch students" });
  }
});

// 🟡 **Get Attendance for an Event**
app.get("/attendance/:eventId", async (req, res) => {
  try {
    const { eventId } = req.params;
    const attendance = await Attendance.find({ eventId });

    let attendanceMap = {};
    attendance.forEach(entry => {
      attendanceMap[entry.studentId] = entry.present;
    });

    console.log(`✅ Attendance fetched for Event ${eventId}:`, attendanceMap);
    res.json(attendanceMap);
  } catch (err) {
    console.error("❌ Error fetching attendance:", err);
    res.status(500).json({ error: "Failed to fetch attendance" });
  }
});

// 🔴 **Update Attendance for an Event**
app.post("/attendance/:eventId", async (req, res) => {
  try {
    const { eventId } = req.params;
    const { studentId, present } = req.body;

    const updatedAttendance = await Attendance.findOneAndUpdate(
      { eventId, studentId },
      { present },
      { new: true, upsert: true }
    );

    console.log(`✅ Attendance updated: ${studentId} - Present: ${present}`);
    res.json({ success: true, data: updatedAttendance });
  } catch (err) {
    console.error("❌ Error updating attendance:", err);
    res.status(500).json({ error: "Failed to update attendance" });
  }
});

app.post('/attendance/submit', async (req, res) => {
  try {
    const { eventId, attendanceData } = req.body;

    if (!eventId || !attendanceData || !Array.isArray(attendanceData)) {
      return res.status(400).json({ message: "Invalid request data." });
    }

    // Check if event exists
    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ message: "Event not found." });
    }

    // Prepare attendance records
    const attendanceRecords = attendanceData.map(item => ({
      studentId: item.studentId,
      present: item.present,
      eventDate: item.eventDate,
      eventId: eventId, // Link attendance to event
    }));

    // Save attendance records in the database
    await Attendance.insertMany(attendanceRecords);

    res.status(200).json({ message: "✅ Attendance submitted successfully!" });
  } catch (err) {
    console.error("❌ Error submitting attendance:", err);
    res.status(500).json({ message: err.message });
  }
});


// Start the server
const PORT = process.env.PORT || 5000;
const HOST = "0.0.0.0"; // Allow external devices to access
app.listen(PORT, HOST, () => console.log(`Server running on http://${HOST}:${PORT}`));
