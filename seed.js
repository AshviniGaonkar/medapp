const { MongoClient, ServerApiVersion } = require('mongodb');

// Replace <db_password> with your actual database password
const uri = "mongodb+srv://gadadeavishkar043:WS0d8CFqxCigdhlX@cluster0.fg17p.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

// Create MongoDB client
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});

// Sample 20 Students Data
const students = [
      { name: "Mr. Ramesh Raghunath Mote",rollNo: "1", prn: "2334080050",attendance: [] },
      { name: "Mr. Colin Adeen Thearode",rollNo: "2", prn: "2334080051",attendance: [] },
      { name: "Ms. Mayuri Mahesh Patil",rollNo: "3", prn: "2334080052",attendance: [] },
      { name: "Ms. Komal Vaijnath Devkar",rollNo: "4", prn: "2334080053", attendance: [] },
      { name: "Mrs. Rutuja Mhatre", rollNo: "5",  prn:"2334080054", attendance: [] },
      { name: "Ms. Shirley Anand Xaxa", rollNo: "6",  prn: "2334080055", attendance: [] },
      { name: "Ms. Surekha Mervan Rathod", rollNo: "7",  prn: "2334080056", attendance: [] },
      { name: "Ms. Aarti Gupta", rollNo: "8",  prn: "2334080057", attendance: [] },
      { name: "Ms. Shrutika Bavkar", rollNo: "9",  prn: "2334080058", attendance: [] },
      { name: "Ms. Pratiksha Agand Mahadik", rollNo: "10",  prn: "2334080059", attendance: [] },
      { name: "Mr. Kunal Sambjaji Shinde", rollNo: "11",  prn: "2334080060", attendance: [] },
      { name: "Mr. Priyanka Baban Ughade", rollNo: "12",  prn: "2334080061", attendance: [] },
      { name: "Ms. Pranali Kishor Tambe", rollNo: "13",  prn: "2334080062", attendance: [] },
      { name: "Ms. Minal Shashikant Jambhale", rollNo: "14",  prn: "2334080063", attendance: [] },
      { name: "Ms. Shriparna Dutta", rollNo: "15",  prn: "2334080064", attendance: [] },
      { name: "Ms. Roshani Vikas Yeole", rollNo: "16",  prn: "2334080065", attendance: [] },
      { name: "Ms. Nitisha Ghode", rollNo: "17",  prn: "2334080066", attendance: [] },
      { name: "Ms. Divya Manohar Sase", rollNo: "18",  prn: "2334080067", attendance: [] },
      { name: "Mrs. Shubhada Vishnu Ghaware", rollNo: "19",  prn: "2334080068", attendance: [] }
  
];

async function insertStudents() {
  try {
    await client.connect();
    const database = client.db("attendanceDB");  // Change 'attendanceDB' if needed
    const collection = database.collection("students");

    // Insert students data
    const result = await collection.insertMany(students);
    console.log(`Inserted ${result.insertedCount} students successfully!`);
  } catch (error) {
    console.error("Error inserting students:", error);
  } finally {
    await client.close();
  }
}

// Run the function
insertStudents();
