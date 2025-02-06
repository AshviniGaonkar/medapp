require("dotenv").config();


const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log("MongoDB Atlas Connected"))
.catch(err => console.error("MongoDB Connection Error:", err));

const app = express();
app.use(cors()); // Allow all origins for development
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url} - Body:`, req.body);
  next();
});


// 🔹 Event Schema
const eventSchema = new mongoose.Schema({
  name: { type: String, required: true },
  location: { type: String, required: true },
  time: { type: String, required: true },
  date: { type: Date, required: true },
});

const studentSchema = new mongoose.Schema({
  name: { type: String, required: true },
  rollNo: { type: String, required: true, unique: true },
  prn: { type: String, required: true, unique: true }
});

// 🔹 Attendance Schema (Updated)
const attendanceSchema = new mongoose.Schema({
  studentId: { type: String, required: true },
  eventId: { type: String, required: true },
  eventDate: { type: String, required: true },
  present: { type: Boolean, required: true },
  submitted: { type: Boolean, default: false } // Lock attendance after submission
}, { timestamps: true });

// Ensure unique attendance per student per event date
attendanceSchema.index({ studentId: 1, eventId: 1, eventDate: 1 }, { unique: true });

// Define models
const Event = mongoose.model("Event", eventSchema);
const Student = mongoose.model("Student", studentSchema);
const Attendance = mongoose.model("Attendance", attendanceSchema);

// 🟢 **Create Event** 
app.post('/events', async (req, res) => {
  try {
    const { name, location, time, date } = req.body;

    if (!name || !location || !time || !date) {
      return res.status(400).json({ message: "All fields are required: name, location, time, date." });
    }

    const event = new Event({ name, location, time, date });
    await event.save();
    res.status(201).json(event);
  } catch (error) {
    console.error("Error creating event:", error);
    res.status(500).json({ message: "Failed to create event." });
  }
});

// 🟢 **Get All Events**
app.get("/events", async (req, res) => {
  try {
    const events = await Event.find();
    res.json(events);
  } catch (err) {
    console.error(" Error fetching events:", err);
    res.status(500).json({ message: "Failed to fetch events" });
  }
});

// 🟢 **Get All Students**
app.get("/students", async (req, res) => {
  try {
    const students = await Student.find();
    console.log(" Students fetched:", students);
    res.json(students);
  } catch (err) {
    console.error(" Error fetching students:", err);
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

    console.log(` Attendance fetched for Event ${eventId}:`, attendanceMap);
    res.json(attendanceMap);
  } catch (err) {
    console.error(" Error fetching attendance:", err);
    res.status(500).json({ error: "Failed to fetch attendance" });
  }
});

// 🔴 **Update Attendance for an Event** (Restricted)
// Update Attendance for a Specific Date
app.post("/attendance/:eventId", async (req, res) => {
  try {
    const { eventId } = req.params;
    const { studentId, present, eventDate } = req.body;

    const updatedAttendance = await Attendance.findOneAndUpdate(
      { eventId, studentId, eventDate }, // Ensure date is checked
      { present },
      { new: true, upsert: true }
    );

    console.log(` Attendance updated: ${studentId} - Present: ${present} on ${eventDate}`);
    res.json({ success: true, data: updatedAttendance });
  } catch (err) {
    console.error(" Error updating attendance:", err);
    res.status(500).json({ error: "Failed to update attendance" });
  }
});

// 🔵 **Submit Attendance (Lock After Submission)**
app.post('/attendance/submit', async (req, res) => {
  try {
    const { eventId, attendanceData } = req.body;

    if (!eventId || !attendanceData || !Array.isArray(attendanceData)) {
      return res.status(400).json({ message: "Invalid request data." });
    }

    // Check if attendance for this event and date is already submitted
    const existingAttendance = await Attendance.findOne({ eventId, eventDate: attendanceData[0].eventDate, submitted: true });

    if (existingAttendance) {
      return res.status(403).json({ message: " Attendance already submitted for this date. Changes are not allowed!" });
    }

    // Prepare attendance records
    const attendanceRecords = attendanceData.map(item => ({
      studentId: item.studentId,
      present: item.present,
      eventDate: item.eventDate,
      eventId: eventId,
      submitted: true // Lock attendance once submitted
    }));

    await Attendance.insertMany(attendanceRecords);
    res.status(200).json({ message: " Attendance submitted successfully!" });
  } catch (err) {
    console.error(" Error submitting attendance:", err);
    res.status(500).json({ message: err.message });
  }
});

// Start the server
const PORT = process.env.PORT || 5000;
const HOST = "0.0.0.0"; // Allow external devices to access
app.listen(5000, '0.0.0.0', () => {
  console.log("Server running on 0.0.0.0:5000");
});
