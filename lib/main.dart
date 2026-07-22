import "package:flutter/material.dart";

void main() {
  runApp(const PocketLedgerApp());
}

class PocketLedgerApp extends StatelessWidget {
  const PocketLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Pocket Ledger",
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Pocket Ledger"),
    ),
    body: const Center(
      child: Text(
        "Welcome to Pocket Ledger!",
        style: TextStyle(fontSize: 24),
      ),
    ),
  );
}
}