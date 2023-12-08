import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const Main(),
    ),
  );
}

/// Main App
class Main extends StatelessWidget {
  /// Constructor
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter QR Scanner Example"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QRScannerPage(),
              ),
            );
          },
          child: const Text("Scan Code"),
        ),
      ),
    );
  }
}

/// QRScannerPage
class QRScannerPage extends StatefulWidget {
  /// QRScannerPage
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey();

  final ValueNotifier<Barcode?> _result = ValueNotifier<Barcode?>(null);

  // In order to get hot reload to work we need to pause the camera
  // if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              overlay: QrScannerOverlayShape(
                cutOutSize: width * 0.7,
              ),
              key: qrKey,
              onPermissionSet: (ctrl, permission) {
                log('onPermissionSet $permission');
                if (!permission) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('no Permission')),
                  );
                }
              },
              onQRViewCreated: (QRViewController ctrl) {
                controller = ctrl;
                ctrl.scannedDataStream.listen((scanData) {
                  _result.value = scanData;
                });
              },
            ),
          ),
          Expanded(
            child: Column(
              children: [
                ValueListenableBuilder(
                  valueListenable: _result,
                  builder: (BuildContext context, Barcode? result, _) {
                    return Text(
                      result != null
                          ? '''
Barcode Type: ${describeEnum(result.format)} \nData: ${result.code}'''
                          : 'Scan a code',
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
                      future: controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        return InkWell(
                          onTap: () async {
                            setState(() async {
                              await controller?.toggleFlash();
                            });
                          },
                          child: Icon(
                            snapshot.data ?? true
                                ? Icons.flash_off
                                : Icons.flash_on,
                            size: height * 0.05,
                          ),
                        );
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
