import 'package:flutter/material.dart';
import 'package:queid/main.dart';
import 'package:queid/mutation.dart';
import 'package:queid/page_home.dart';
import 'package:queid/profile.dart';
import 'package:queid/scan.dart';
import 'package:queid/wallet.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _pages = [
    HomePage(),
    Mutation(),
    SizedBox.shrink(),
    Wallet(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QUE.ID', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_index],
      floatingActionButton: FloatingActionButton(
        backgroundColor: BIRU,
        child: Image.asset('img/ic_scan.png', height: 24, width: 24),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ScanQR()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (x) {
          setState(() {
            _index = x;
          });
        },
        selectedItemColor: BIRU,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'img/ic_home.png',
              height: 24,
              width: 24,
            ),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'img/ic_mutation.png',
              height: 24,
              width: 24,
            ),
            title: Text('Mutation'),
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            title: SizedBox.shrink(),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'img/ic_wallet.png',
              height: 24,
              width: 24,
            ),
            title: Text('Wallet'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'img/ic_profile.png',
              height: 24,
              width: 24,
            ),
            title: Text('Profile'),
          ),
        ],
      ),
    );
  }
}
