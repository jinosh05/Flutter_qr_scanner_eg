import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: const MyHome(),
  ));
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter QR Scanner Example"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const QRScannerPage(),
              ));
            },
            child: const Text("Scan Code")),
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey();

  final ValueNotifier<Barcode?> _result = ValueNotifier<Barcode?>(null);

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
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
                log('${DateTime.now().toIso8601String()}_onPermissionSet $permission');
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
              flex: 1,
              child: Column(
                children: [
                  ValueListenableBuilder(
                    valueListenable: _result,
                    builder: (BuildContext context, Barcode? result, _) {
                      if (result != null) {
                        return Text(
                            'Barcode Type: ${describeEnum(result.format)} \nData: ${result.code}');
                      } else {
                        return const Text('Scan a code');
                      }
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
