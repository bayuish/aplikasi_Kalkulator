import 'package:flutter/material.dart';
import '../screens/Homepage_screen.dart';
import '../screens/SudentDataEntry_Screen.dart';
import '../screens/calculator_screen.dart';
import '../screens/imagebuilder_screen.dart';



class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavBar({super.key, this.currentIndex = 0});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomepageScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalculatorScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDataEntryScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ImageBuilderScreen()),
        );
        break;
    // Kamu bisa lanjutkan untuk case index 3-5 nanti.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
        BottomNavigationBarItem(icon: Icon(Icons.dataset), label: 'Data Entry'),
        BottomNavigationBarItem(icon: Icon(Icons.imagesearch_roller), label: 'Image Builder'),
      ],
    );
  }
}