import 'package:cooky/pages/createPost/PostCreationPage.dart';
import 'package:cooky/pages/home/HomePage.dart';
import 'package:cooky/pages/profile/ProfilePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarPage extends StatefulWidget {
  const BottomNavigationBarPage({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarPage> createState() => _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  int _pageSelectedIndex = 0;

  List<Widget> _userNavigationItems = <Widget>[
    HomePage(),
    PostCreationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: _userNavigationItems.elementAt(_pageSelectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: "Create a post",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
        currentIndex: _pageSelectedIndex,
        unselectedItemColor: Colors.orangeAccent,
        selectedItemColor: Colors.deepOrange,
        onTap: (value) => _onItemSelected(value),
      ),
    );
  }

  void _onItemSelected(int index) {
    setState(() {
      _pageSelectedIndex = index;
    });
  }

}
