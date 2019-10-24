import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
              controller.scannedDataStream.listen((data) {
                print(data);
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
