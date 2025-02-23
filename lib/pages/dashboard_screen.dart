import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedYear = '2021';
  String selectedMonth = 'Aug';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Student',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedYear,
                  items: ['2021', '2022', '2023'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedMonth,
                  items: [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 20),

            // Profile cards
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                shrinkWrap: true, // Added shrinkWrap to avoid overflow
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: 150,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              radius: 30,
                              child: Icon(Icons.person,
                                  size: 30, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Jessica Goldsmith',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text('Software Engineer',
                                      style: TextStyle(fontSize: 12)),
                                  TextButton(
                                      onPressed: () {},
                                      child: Text('Profile Details',
                                          style: TextStyle(fontSize: 10)))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Scrollable Data Table inside a horizontal scroll view
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Card(
                elevation: 4,
                child: DataTable(
                  columnSpacing: 30,
                  columns: [
                    DataColumn(label: Text('Student')),
                    DataColumn(label: Text('Class')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Check-in Time')),
                    DataColumn(label: Text('Checkout Time')),
                    DataColumn(label: Text('Details')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('John Doe')),
                      DataCell(Text('10th')),
                      DataCell(Text('20-08-2021')),
                      DataCell(Text('08:00 AM')),
                      DataCell(Text('05:00 PM')),
                      DataCell(
                          TextButton(onPressed: () {}, child: Text('View'))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Jane Smith')),
                      DataCell(Text('12th')),
                      DataCell(Text('20-08-2021')),
                      DataCell(Text('09:00 AM')),
                      DataCell(Text('06:00 PM')),
                      DataCell(
                          TextButton(onPressed: () {}, child: Text('View'))),
                    ]),
                    // Add more rows as necessary
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}