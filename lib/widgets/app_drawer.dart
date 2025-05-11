import 'package:flutter/material.dart';
import '../screens/export_screen.dart';
import '../screens/import_screen.dart';
import '../screens/statistics_dashboard_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.amber),
            child: Text('UACS Birthday Reminder',
                style: TextStyle(color: Colors.black, fontSize: 20)),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ExportScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ImportScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const StatisticsDashboardScreen()));
            },
          ),
        ],
      ),
    );
  }
}
