import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:queid/home.dart';
import 'package:queid/main.dart';

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

class DetailPengguna extends StatefulWidget {
  @override
  _DetailPenggunaState createState() => _DetailPenggunaState();
}

class _DetailPenggunaState extends State<DetailPengguna> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _npwpController = TextEditingController();

  DateTime _tglLahir = DateTime(DateTime.now().year - 20);
  String _pin;

  void _submit() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection('pengguna').document(user.uid).setData({
      'nama': _namaController.text,
      'nomor': user.phoneNumber,
      'nik': _nikController.text,
      'tglLahir': Timestamp.fromDate(_tglLahir),
      'alamat': _alamatController.text,
      'npwp': _npwpController.text,
      'pin': _pin,
      'created_at': FieldValue.serverTimestamp(),
    });
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  void _createPin() async {
    if (_namaController.text.isEmpty ||
        _nikController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _npwpController.text.isEmpty) return;

    _pin = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => CreatePIN()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama Lengkap'),
            ),
            SizedBox(height: 16),
            FutureBuilder<FirebaseUser>(
              future: FirebaseAuth.instance.currentUser(),
              builder: (context, a) {
                return Text(a.data?.phoneNumber ?? '');
              },
            ),
            TextField(
              controller: _nikController,
              decoration: InputDecoration(labelText: 'NIK'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            FlatButton(
              child: Text(
                  '${_tglLahir.day} ${BULAN[_tglLahir.month - 1]} ${_tglLahir.year}'),
              onPressed: () async {
                DateTime result = await showDatePicker(
                  context: context,
                  initialDate: _tglLahir,
                  firstDate: DateTime(1945),
                  lastDate: DateTime(DateTime.now().year - 17),
                  initialDatePickerMode: DatePickerMode.year,
                );
                if (result == null) return;
                setState(() {
                  _tglLahir = result;
                });
              },
            ),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: _npwpController,
              decoration: InputDecoration(labelText: 'NPWP'),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text(_pin == null ? 'CREATE PIN' : 'SUBMIT'),
              onPressed: _pin == null ? _createPin : _submit,
            ),
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
  final TextEditingController _controller = TextEditingController();

  String _pin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${_pin == null ? 'Create' : 'Verify'} 4-digit PIN',
            style: TextStyle(fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: PinInputTextField(
              controller: _controller,
              autoFocus: true,
              pinLength: 4,
              keyboardType: TextInputType.number,
              onSubmit: (pin) {
                if (_pin == null) {
                  _controller.clear();
                  setState(() {
                    _pin = pin;
                  });
                } else {
                  if (_pin == pin) {
                    Navigator.of(context).pop(pin);
                  }
                }
              },
              decoration: BoxLooseDecoration(
                textStyle: TextStyle(),
                strokeColor: Color(0xFFD4E4FF),
                solidColor: Colors.transparent,
                strokeWidth: 32,
                radius: Radius.circular(20),
                enteredColor: Color(0xFF4C89F0),
                obscureStyle: ObscureStyle(
                  isTextObscure: true,
                  obscureText: ' ',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
                'To protect the security of your Que.id wallet, please create a 4-digit PIN. You will use this each time you open this app.'),
          ),
        ],
      ),
    );
  }
}
