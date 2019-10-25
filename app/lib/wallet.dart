import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  DocumentReference _ref;
  String _nama;

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
    _nama = ds.data['nama'];

    setState(() {
      _ref = ds.reference;
    });
  }

  void _addBank() {
    Random r = Random();
    _ref.collection('bank').add({
      'bank': ['Bank NARUTO', 'Bank SASUKE', 'Bank HOKAGE'][r.nextInt(3)],
      'nama': _nama,
      'no_rek': (r.nextInt(4294967296) * 11 + 100000000000),
      'saldo': (r.nextInt(10000000) + 1000000),
      'pin': '123456',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Widget _listBuilder(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) return Text(snapshot.error);
    if (snapshot.connectionState == ConnectionState.waiting)
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      );
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        children: snapshot.data.documents.map((doc) {
          String card;
          switch (doc.data['bank']) {
            case 'Bank NARUTO':
              card = 'img/card_naruto.png';
              break;
            case 'Bank SASUKE':
              card = 'img/card_sasuke.png';
              break;
            case 'Bank HOKAGE':
              card = 'img/card_hokage.png';
              break;
            default:
              card = 'img/card_naruto.png';
          }
          return GestureDetector(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.asset(card),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        doc.data['bank'],
                        textAlign: TextAlign.end,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 24),
                      Text(
                        doc.data['no_rek'].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      SizedBox(height: 24),
                      Text(
                        doc.data['nama'],
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DetailWallet(ds: doc)));
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ref == null
        ? Center(child: CircularProgressIndicator())
        : Center(
            child: Column(
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                  stream: _ref
                      .collection('bank')
                      .orderBy('created_at', descending: true)
                      .snapshots(),
                  builder: _listBuilder,
                ),
                SizedBox(height: 16),
                FlatButton(
                  child: Text('ADD BANK ACCOUNT'),
                  onPressed: _addBank,
                ),
                SizedBox(height: 16),
              ],
            ),
          );
  }
}

class DetailWallet extends StatefulWidget {
  final DocumentSnapshot ds;

  const DetailWallet({Key key, @required this.ds}) : super(key: key);
  @override
  _DetailWalletState createState() => _DetailWalletState();
}

class _DetailWalletState extends State<DetailWallet> {
  bool _auth = false;

  @override
  Widget build(BuildContext context) {
    String card;
    switch (widget.ds.data['bank']) {
      case 'Bank NARUTO':
        card = 'img/card_naruto.png';
        break;
      case 'Bank SASUKE':
        card = 'img/card_sasuke.png';
        break;
      case 'Bank HOKAGE':
        card = 'img/card_hokage.png';
        break;
      default:
        card = 'img/card_naruto.png';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Account'),
      ),
      body: _auth
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Image.asset(card),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            widget.ds.data['bank'],
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 24),
                          Text(
                            widget.ds.data['no_rek'].toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          SizedBox(height: 24),
                          Text(
                            widget.ds.data['nama'],
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Bank'),
                      Text(
                        widget.ds.data['bank'],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 24),
                      Text('Nama'),
                      Text(
                        widget.ds.data['nama'],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 24),
                      Text('Nomor rekening'),
                      Text(
                        widget.ds.data['no_rek'].toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 24),
                      Text('Saldo'),
                      Text(
                        'Rp ' + widget.ds.data['saldo'].toString() + ',00',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Container(
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
                    SizedBox(height: 16),
                    Text(
                      'Enter your bank PIN',
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: PinInputTextField(
                        autoFocus: true,
                        pinLength: 6,
                        keyboardType: TextInputType.number,
                        onSubmit: (pin) {
                          if (pin == widget.ds.data['pin']) {
                            setState(() {
                              _auth = true;
                            });
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        decoration: BoxLooseDecoration(
                          textStyle: TextStyle(fontSize: 1),
                          strokeColor: Colors.white10,
                          solidColor: Colors.transparent,
                          strokeWidth: 20,
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
