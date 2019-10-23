import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:queid/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _checkAuth() async {
    setState(() {
      _isLoading = true;
    });
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
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Image.asset('img/splash.png'),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 48),
                color: Colors.white,
                child: _isLoading
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(),
                      )
                    : Text(
                        'LOG IN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                onPressed: _isLoading ? null : _checkAuth,
              ),
              SizedBox(height: 96),
            ],
          ),
        ],
      ),
    );
  }
}
