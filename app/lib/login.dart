import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:queid/home.dart';

class LoginPIN extends StatefulWidget {
  @override
  _LoginPINState createState() => _LoginPINState();
}

class _LoginPINState extends State<LoginPIN> {
  final TextEditingController _controller = TextEditingController();

  String _nama = '';
  String _pin = '';

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot ds = await Firestore.instance
        .collection('pengguna')
        .document(user.uid)
        .get();
    setState(() {
      _nama = ds.data['nama'];
      _pin = ds.data['pin'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login PIN'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _nama,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'PIN'),
              maxLength: 6,
              obscureText: true,
            ),
            RaisedButton(
              child: Text('LOGIN'),
              onPressed: () async {
                if (_controller.text.isEmpty) return;

                if (_pin == _controller.text) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                    (r) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LoginOTP extends StatefulWidget {
  @override
  _LoginOTPState createState() => _LoginOTPState();
}

class _LoginOTPState extends State<LoginOTP> {
  final TextEditingController _controller = TextEditingController();

  bool _isKode = false;
  String _verificationId = '';
  String _nomor;

  void kirimKode() async {
    _nomor = _controller.text;

    if (_nomor.isEmpty) return;

    if (_nomor.startsWith('0')) {
      _nomor = _nomor.replaceFirst('0', '+62');
    }
    print(_nomor);
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _nomor,
      codeAutoRetrievalTimeout: (s) => _verificationId = s,
      codeSent: (s, [i]) {
        print('HERE');
        _verificationId = s;
        _controller.clear();
        setState(() {
          _isKode = true;
        });
      },
      timeout: Duration(minutes: 1),
      verificationFailed: (e) => print(e.message),
      verificationCompleted: (AuthCredential credential) =>
          updateKredensial(credential),
    );
  }

  void verifikasiKode() {
    print('SINI');
    AuthCredential credential = PhoneAuthProvider.getCredential(
      smsCode: _controller.text,
      verificationId: _verificationId,
    );
    updateKredensial(credential);
  }

  void updateKredensial(AuthCredential credential) async {
    AuthResult result;
    try {
      result = await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      _controller.clear();
      return;
    }

    DocumentSnapshot ds = await Firestore.instance
        .collection('pengguna')
        .document(result.user.uid)
        .get();
    if (ds.exists) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPIN(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DetailPengguna(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: _isKode ? 'Kode SMS' : 'Nomor Handphone',
              ),
              textAlign: TextAlign.center,
              keyboardType:
                  _isKode ? TextInputType.number : TextInputType.phone,
            ),
            SizedBox(height: 8),
            RaisedButton(
              onPressed: _isKode ? verifikasiKode : kirimKode,
              child: Text(_isKode ? 'VERIFIKASI' : 'KIRIM KODE'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPengguna extends StatelessWidget {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pin2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _namaController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(hintText: 'Nama Lengkap'),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _pinController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'PIN Baru'),
              maxLength: 6,
              obscureText: true,
            ),
            TextField(
              controller: _pin2Controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Konfirmasi PIN'),
              maxLength: 6,
              obscureText: true,
            ),
            RaisedButton(
              child: Text('OK'),
              onPressed: () async {
                if (_namaController.text.isEmpty ||
                    _pinController.text.isEmpty ||
                    _pin2Controller.text.isEmpty) return;

                if (_pinController.text != _pin2Controller.text) return;

                if (_pinController.text.length != 6) return;

                FirebaseUser user = await FirebaseAuth.instance.currentUser();
                await Firestore.instance
                    .collection('pengguna')
                    .document(user.uid)
                    .setData({
                  'nama': _namaController.text,
                  'nomor': user.phoneNumber,
                  'pin': _pinController.text,
                });

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                  (r) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
