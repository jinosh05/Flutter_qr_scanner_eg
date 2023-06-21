import 'package:flutter/material.dart';

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
        child: ElevatedButton(onPressed: () {}, child: const Text("Scan Code")),
      ),
    );
  }
}
