import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 10, 168, 212),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: GNav(
          backgroundColor: const Color.fromARGB(255, 10, 168, 212),
          color: const Color.fromARGB(255, 11, 11, 11),
          activeColor: const Color.fromARGB(255, 18, 17, 17),
          tabBackgroundColor: const Color.fromARGB(255, 245, 244, 244),
          gap: 8,
          padding: EdgeInsets.all(16),
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
          tabs: [
            GButton(icon: Icons.home, text: "Home"),
            GButton(icon: Icons.event, text: "Events"),
            GButton(icon: Icons.man_3_rounded, text: "Attendance"),
            GButton(icon: Icons.dashboard, text: "Dashboard"),
            
          ],
        ),
      ),
    );
  }
}
