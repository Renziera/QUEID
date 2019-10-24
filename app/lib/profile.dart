import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:queid/main.dart';
import 'package:queid/splash.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DocumentSnapshot _ds;
  DateTime _tglLahir;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    _ds = await Firestore.instance
        .collection('pengguna')
        .document(user.uid)
        .get();

    Timestamp ts = _ds.data['tglLahir'];
    _tglLahir = ts.toDate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _ds == null
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_ds.data['nama'], style: TextStyle(fontSize: 20)),
                Text(_ds.data['nik'], style: TextStyle(fontSize: 20)),
                Text(
                    '${_tglLahir.day} ${BULAN[_tglLahir.month - 1]} ${_tglLahir.year}',
                    style: TextStyle(fontSize: 20)),
                Text(_ds.data['nomor'], style: TextStyle(fontSize: 20)),
                Text(_ds.data['alamat'], style: TextStyle(fontSize: 20)),
                Text(_ds.data['npwp'], style: TextStyle(fontSize: 20)),
                RaisedButton(
                  child: Text('LOG OUT'),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => SplashScreen()));
                  },
                )
              ],
            ),
          );
  }
}
