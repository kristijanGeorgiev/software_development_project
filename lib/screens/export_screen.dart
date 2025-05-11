import 'package:flutter/material.dart';
import '../../utilities/birthday_data.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _groupController = TextEditingController(text: '0');
  final TextEditingController _startController = TextEditingController(text: '1');
  final TextEditingController _endController = TextEditingController(text: '10');

  void _exportData(BuildContext context) async {
    final String name = _nameController.text.trim();
    final int birthdayGroup = int.tryParse(_groupController.text) ?? 0;
    final int startIndex = int.tryParse(_startController.text) ?? 1;
    final int endIndex = int.tryParse(_endController.text) ?? 10;

    try {
      await ExportBirthdays(
        name: name,
        birthdayGroup: birthdayGroup,
        startIndex: startIndex,
        endIndex: endIndex,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export Data"), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/images/export.png', height: 180),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _groupController,
              decoration: const InputDecoration(labelText: 'Birthday Group'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _startController,
              decoration: const InputDecoration(labelText: 'Start Index'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _endController,
              decoration: const InputDecoration(labelText: 'End Index'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _exportData(context),
              child: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }
}

