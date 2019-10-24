import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuePoints extends StatefulWidget {
  @override
  _QuePointsState createState() => _QuePointsState();
}

class _QuePointsState extends State<QuePoints> {
  String _nama;
  String _poin;

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
      _poin = ds.data['poin'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Que Points'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5191F1), Color(0xFF2A51D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _nama == null
            ? Center(
                child: CircularProgressIndicator(backgroundColor: Colors.grey),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    _nama,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '$_poin points',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 64),
                  Text(
                    'Vouchers',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  Image.asset('img/voucher_yoshinoya.png'),
                  Image.asset('img/voucher_hokben.png'),
                  Image.asset('img/voucher_yoshinoya.png'),
                ],
              ),
      ),
    );
  }
}
