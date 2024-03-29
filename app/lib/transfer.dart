import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:queid/scan.dart';

class Transfer extends StatefulWidget {
  @override
  _TransferState createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  String _bankTujuan = 'Bank NARUTO';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Pilih bank tujuan'),
              DropdownButton<String>(
                value: _bankTujuan,
                items: ['Bank NARUTO', 'Bank SASUKE', 'Bank HOKAGE'].map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _bankTujuan = value;
                  });
                },
              ),
              SizedBox(height: 24),
              Text('Nomor rekening penerima'),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              RaisedButton(
                child: Text('TRANSFER REKENING'),
                onPressed: () async {
                  if (_controller.text.isEmpty) return;
                  int noRek = int.parse(_controller.text);
                  QuerySnapshot snapshot = await Firestore.instance
                      .collectionGroup('bank')
                      .where('bank', isEqualTo: _bankTujuan)
                      .where('no_rek', isEqualTo: noRek)
                      .limit(1)
                      .getDocuments();
                  if (snapshot.documents.isEmpty) return;
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => PilihRekAsal(
                        tujuan: snapshot.documents.first,
                        uid: user.uid,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),
              Text('QUEID penerima'),
              TextField(
                controller: _usernameController,
              ),
              SizedBox(height: 24),
              RaisedButton(
                child: Text('TRANSFER QUEID'),
                onPressed: () async {
                  if (_usernameController.text.isEmpty) return;
                  QuerySnapshot snapshot = await Firestore.instance
                      .collection('pengguna')
                      .where('username', isEqualTo: _usernameController.text)
                      .getDocuments();
                  if (snapshot.documents.isEmpty) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => PilihRekTujuan(
                        uid: snapshot.documents.first.documentID,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PilihRekAsal extends StatefulWidget {
  final DocumentSnapshot tujuan;
  final String uid;

  const PilihRekAsal({Key key, @required this.tujuan, @required this.uid})
      : super(key: key);
  @override
  _PilihRekAsalState createState() => _PilihRekAsalState();
}

class _PilihRekAsalState extends State<PilihRekAsal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 16),
            Text('Choose Your Bank Account to Transfer'),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('pengguna')
                  .document(widget.uid)
                  .collection('bank')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    return Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: snapshot.data.documents.map((doc) {
                          return ListTile(
                            title: Text(doc.data['bank']),
                            subtitle: Text(
                                '${doc.data['nama']}\n${doc.data['no_rek']}'),
                            isThreeLine: true,
                            trailing: Icon(Icons.navigate_next),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => TransferNominal(
                                    asal: doc,
                                    tujuan: widget.tujuan,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
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

class TransferNominal extends StatefulWidget {
  final DocumentSnapshot asal;
  final DocumentSnapshot tujuan;

  const TransferNominal({Key key, @required this.asal, @required this.tujuan})
      : super(key: key);
  @override
  _TransferNominalState createState() => _TransferNominalState();
}

class _TransferNominalState extends State<TransferNominal> {
  final TextEditingController _controller = TextEditingController();

  Widget _body;

  @override
  void initState() {
    _body = _buildPIN();
    super.initState();
  }

  void _transfer() async {
    if (_controller.text.isEmpty) return;
    int nominal = int.parse(_controller.text);
    if (widget.asal.data['saldo'] < nominal) return;
    setState(() {
      _body = Center(child: CircularProgressIndicator());
    });

    WriteBatch batch = Firestore.instance.batch();
    batch.updateData(
        widget.asal.reference, {'saldo': FieldValue.increment(-nominal)});
    batch.updateData(
        widget.tujuan.reference, {'saldo': FieldValue.increment(nominal)});
    batch.setData(
        widget.asal.reference.parent().parent().collection('mutasi').document(),
        {
          'send': true,
          'nama_asal': widget.asal.data['nama'],
          'nama_tujuan': widget.tujuan.data['nama'],
          'bank_asal': widget.asal.data['bank'],
          'bank_tujuan': widget.tujuan.data['bank'],
          'rek_asal': widget.asal.data['no_rek'],
          'rek_tujuan': widget.tujuan.data['no_rek'],
          'nominal': nominal,
          'waktu': FieldValue.serverTimestamp(),
        });
    batch.setData(
        widget.tujuan.reference
            .parent()
            .parent()
            .collection('mutasi')
            .document(),
        {
          'send': false,
          'nama_asal': widget.asal.data['nama'],
          'nama_tujuan': widget.tujuan.data['nama'],
          'bank_asal': widget.asal.data['bank'],
          'bank_tujuan': widget.tujuan.data['bank'],
          'rek_asal': widget.asal.data['no_rek'],
          'rek_tujuan': widget.tujuan.data['no_rek'],
          'nominal': nominal,
          'waktu': FieldValue.serverTimestamp(),
        });
    await batch.commit();

    setState(() {
      _body = _buildBerhasil(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
      ),
      body: _body,
    );
  }

  Widget _buildPIN() {
    return Container(
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
                  if (pin != widget.asal.data['pin']) return;
                  setState(() {
                    _body = _buildDetail();
                  });
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
    );
  }

  Widget _buildBerhasil(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 196,
          ),
          Text('Transfer Berhasil'),
          SizedBox(height: 16),
          RaisedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetail() {
    return Column(
      children: <Widget>[
        SizedBox(height: 24),
        Text('Rekening Asal'),
        ListTile(
          title: Text(widget.asal.data['bank']),
          subtitle: Text(
              '${widget.asal.data['nama']}\n${widget.asal.data['no_rek']}'),
          isThreeLine: true,
        ),
        Text('Rekening Tujuan'),
        ListTile(
          title: Text(widget.tujuan.data['bank']),
          subtitle: Text(
              '${widget.tujuan.data['nama']}\n${widget.tujuan.data['no_rek']}'),
          isThreeLine: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Nominal'),
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 24),
        RaisedButton(
          child: Text('Transfer'),
          onPressed: _transfer,
        ),
      ],
    );
  }
}
