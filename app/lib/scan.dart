import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:queid/transfer.dart';

class ScanQR extends StatefulWidget {
  @override
  _ScanQRState createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          QRView(
            key: GlobalKey(debugLabel: 'QR'),
            onQRViewCreated: (QRViewController controller) {
              controller.scannedDataStream.listen((data) async {
                controller.pauseCamera();
                QuerySnapshot qs = await Firestore.instance
                    .collection('pengguna')
                    .where('username', isEqualTo: data)
                    .getDocuments();
                if (qs.documents.isNotEmpty) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          PilihRekTujuan(uid: qs.documents.first.documentID)));
                } else {
                  controller.resumeCamera();
                }
              });
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset('img/ic_scan.png'),
              Text(
                'Scan QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 72),
            ],
          ),
        ],
      ),
    );
  }
}

class PilihRekTujuan extends StatefulWidget {
  final String uid;

  const PilihRekTujuan({Key key, @required this.uid}) : super(key: key);
  @override
  _PilihRekTujuanState createState() => _PilihRekTujuanState();
}

class _PilihRekTujuanState extends State<PilihRekTujuan> {
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
            Text('Choose Destination Bank Account to Transfer'),
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
                            onTap: () async {
                              FirebaseUser user =
                                  await FirebaseAuth.instance.currentUser();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => PilihRekAsal(
                                    tujuan: doc,
                                    uid: user.uid,
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
