import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5191F1),
              Color(0xFF2A51D2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _nama ?? '',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                'Enter Your 4-digit PIN',
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: PinInputTextField(
                  autoFocus: true,
                  pinLength: 4,
                  keyboardType: TextInputType.number,
                  onSubmit: (pin) {
                    if (pin.isEmpty) return;
                    if (pin != _pin) return;
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                        (r) => false);
                  },
                  decoration: BoxLooseDecoration(
                    textStyle: TextStyle(),
                    strokeColor: Colors.white10,
                    solidColor: Colors.transparent,
                    strokeWidth: 32,
                    radius: Radius.circular(20),
                    enteredColor: Colors.white,
                    obscureStyle: ObscureStyle(
                      isTextObscure: true,
                      obscureText: ' ',
                    ),
                  ),
                ),
              ),
            ],
          ),
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

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _nomor,
      codeAutoRetrievalTimeout: (s) => _verificationId = s,
      codeSent: (s, [i]) {
        _verificationId = s;
        _controller.clear();
        setState(() {
          _isKode = true;
        });
      },
      timeout: Duration(minutes: 1),
      verificationFailed: (e) => _controller.clear(),
      verificationCompleted: (AuthCredential credential) =>
          updateKredensial(credential),
    );
  }

  void verifikasiKode() {
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
        title: Text('Log In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText:
                    _isKode ? 'Enter OTP Code' : 'Enter your mobile number',
              ),
              textAlign: TextAlign.center,
              keyboardType:
                  _isKode ? TextInputType.number : TextInputType.phone,
            ),
            SizedBox(height: 8),
            RaisedButton(
              onPressed: _isKode ? verifikasiKode : kirimKode,
              child: Text(_isKode ? 'VERIFY  OTP' : 'SEND CODE'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPengguna extends StatelessWidget {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _npwpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(),
          ],
        ),
      )),
    );
  }
}

class CreatePIN extends StatefulWidget {
  @override
  _CreatePINState createState() => _CreatePINState();
}

class _CreatePINState extends State<CreatePIN> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
    );
  }
}