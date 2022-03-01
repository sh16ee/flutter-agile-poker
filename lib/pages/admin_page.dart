import 'package:flutter/material.dart';
import 'package:flutter_agile_poker/pages/admin_tasks_page.dart';
import 'package:flutter_agile_poker/pages/admin_voters_page.dart';

class AdminPage extends StatefulWidget {
  AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  int _selectedIndex = 0;
  
  static List<Widget> _widgetOptions = <Widget>[
    AdminVotersPage(),
    AdminTasksPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Voters"),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks")
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}