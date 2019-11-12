import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queid/points.dart';
import 'package:queid/transfer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _nama;
  String _id;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot ds = await Firestore.instance
        .collection('pengguna')
        .document(user.uid)
        .get();
    setState(() {
      _nama = ds.data['nama'];
      _id = ds.data['username'] ?? ds.documentID;
    });
  }

  void _showQueId() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
        ),
        builder: (BuildContext context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _nama ?? '',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(_id ?? ''),
              SizedBox(height: 24),
              QrImage(
                data: _id,
                size: 256,
              ),
              SizedBox(height: 24),
              Text('Scan this code to access your Que ID'),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                Image.asset('img/que_card.png'),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Que ID',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFFDC9A13)),
                      ),
                      Text(
                        _id ?? '',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Nama',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFFDC9A13)),
                      ),
                      Text(
                        _nama ?? '',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FlatButton(
                    child: Image.asset('img/transfer.png'),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Transfer()));
                    },
                  ),
                  Text('Transfer'),
                ],
              ),
              Column(
                children: <Widget>[
                  FlatButton(
                    child: Image.asset('img/point.png'),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => QuePoints()));
                    },
                  ),
                  Text('Que Points'),
                ],
              ),
              Column(
                children: <Widget>[
                  FlatButton(
                    child: Image.asset('img/queid.png'),
                    onPressed: _showQueId,
                  ),
                  Text('Que ID'),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FlatButton(
                    child: Image.asset('img/pln.png'),
                    onPressed: () {},
                  ),
                  Text('PLN'),
                ],
              ),
              Column(
                children: <Widget>[
                  FlatButton(
                    child: Image.asset('img/bpjs.png'),
                    onPressed: () {},
                  ),
                  Text('BPJS'),
                ],
              ),
              Column(
                children: <Widget>[
                  FlatButton(
                    child: Image.asset('img/more.png'),
                    onPressed: () {},
                  ),
                  Text('See More'),
                ],
              ),
            ],
          ),
          SizedBox(height: 32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                SizedBox(width: 24),
                Image.asset(
                  'img/iklan1.png',
                  height: 200,
                ),
                SizedBox(width: 24),
                Image.asset(
                  'img/iklan2.png',
                  height: 200,
                ),
                SizedBox(width: 24),
                Image.asset(
                  'img/iklan3.png',
                  height: 200,
                ),
                SizedBox(width: 24),
              ],
            ),
          ),
          SizedBox(height: 32),
          Image.asset(
            'img/iklan4.jpg',
            height: 200,
          ),
          SizedBox(height: 24),
          Image.asset(
            'img/iklan5.jpg',
            height: 200,
          ),
          SizedBox(height: 24),
          Image.asset(
            'img/iklan6.jpg',
            height: 200,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
