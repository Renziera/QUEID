
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.green,
              height: 180,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  color: Colors.amber,
                  width: 84,
                  height: 84,
                ),
                Container(
                  color: Colors.brown,
                  width: 84,
                  height: 84,
                ),
                Container(
                  color: Colors.cyan,
                  width: 84,
                  height: 84,
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  color: Colors.yellow,
                  width: 84,
                  height: 84,
                ),
                Container(
                  color: Colors.purple,
                  width: 84,
                  height: 84,
                ),
                Container(
                  color: Colors.lime,
                  width: 84,
                  height: 84,
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              color: Colors.red,
              height: 128,
            ),
            SizedBox(height: 24),
            Container(
              color: Colors.indigo,
              height: 128,
            ),
          ],
        ),
      ),
    );
  }
}