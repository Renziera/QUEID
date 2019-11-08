import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:queid/main.dart';

class Mutation extends StatefulWidget {
  @override
  _MutationState createState() => _MutationState();
}

class _MutationState extends State<Mutation> {
  String _id;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _id = user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _id == null
        ? Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('pengguna')
                .document(_id)
                .collection('mutasi')
                .orderBy('waktu', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  return ListView(
                    children:
                        snapshot.data.documents.map((DocumentSnapshot doc) {
                      Timestamp ts = doc.data['waktu'];
                      DateTime waktu = ts.toDate();
                      return ListTile(
                        isThreeLine: true,
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text(
                                      'From ${doc.data['nama_asal']}\n${doc.data['bank_asal']}\n${doc.data['rek_asal']}\n\nTo ${doc.data['nama_tujuan']}\n${doc.data['bank_tujuan']}\n${doc.data['rek_tujuan']}\n\n${waktu.day} ${BULAN[waktu.month - 1]} ${waktu.year} ${waktu.hour}:${waktu.minute}:${waktu.second}'),
                                );
                              });
                        },
                        leading: doc.data['send']
                            ? Image.asset('img/ic_send.png')
                            : Image.asset('img/ic_receive.png'),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(doc.data['send'] ? 'Send' : 'Receive', style: TextStyle(fontWeight: FontWeight.bold),),
                            Text('Rp${doc.data['nominal']},00', style: TextStyle(color: BIRU),),
                          ],
                        ),
                        subtitle: Text((doc.data['send']
                                ? doc.data['bank_asal']
                                : doc.data['bank_tujuan']) +
                            '\n${waktu.day} ${BULAN[waktu.month - 1]} ${waktu.year}'),
                      );
                    }).toList(),
                  );
              }
            },
          );
  }
}
