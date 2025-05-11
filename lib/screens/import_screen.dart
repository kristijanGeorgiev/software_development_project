import 'package:flutter/material.dart';
import '../utilities/birthday_data.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  void _importData(BuildContext context) async {
    try {
      await ImportBirthdays();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Import Data"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset('assets/images/import.png', height: 180),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _importData(context),
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }
}