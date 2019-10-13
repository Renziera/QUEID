import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:queid/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  void checkAuth() async {
    await Future.delayed(Duration(milliseconds: 500));
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      DocumentSnapshot ds = await Firestore.instance
          .collection('pengguna')
          .document(user.uid)
          .get();
      if (ds.exists) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPIN()));
        return;
      }
      await FirebaseAuth.instance.signOut();
    }
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginOTP()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'QUE.ID',
          style: TextStyle(fontSize: 64),
        ),
      ),
    );
  }
}
