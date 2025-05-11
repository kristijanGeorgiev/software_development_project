import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../utilities/constants.dart';
import '../utilities/birthday.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  const StatisticsDashboardScreen({Key? key}) : super(key: key);

  @override
  _StatisticsDashboardScreenState createState() => _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen> {
  Map<String, int> birthdaysByMonth = {};
  Map<String, int> birthdaysByAgeGroup = {};
  Map<String, int> birthdaysByGroup = {};

  bool isLoading = true;

  int? selectedFromYear;
  int? selectedToYear;
  String? selectedGroupId;
  List<Birthday> allBirthdays = [];

  final List<Color> groupColors = [
    Colors.red, Colors.blue, Colors.green, Colors.orange,
    Colors.purple, Colors.teal, Colors.amber, Colors.indigo,
    Colors.pink, Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    fetchBirthdays();
  }

  Future<void> fetchBirthdays() async {
    try {
      final response = await http.get(Uri.parse('${Constants.apiBaseUrl}/Birthday?startIndex=1&endIndex=9999'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        allBirthdays = jsonList.map((e) => Birthday.fromJson(e)).toList();
        applyFilters();
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void applyFilters() {
    List<Birthday> filtered = allBirthdays;

    if (selectedFromYear != null) {
      filtered = filtered.where((b) => b.date.year >= selectedFromYear!).toList();
    }
    if (selectedToYear != null) {
      filtered = filtered.where((b) => b.date.year <= selectedToYear!).toList();
    }
    if (selectedGroupId != null) {
      filtered = filtered.where((b) => b.birthdayGroupId.toString() == selectedGroupId).toList();
    }

    Map<String, int> monthMap = {};
    Map<String, int> ageMap = {};

    for (var b in filtered) {
      final month = b.date.month.toString().padLeft(2, '0');
      monthMap[month] = (monthMap[month] ?? 0) + 1;

      final age = DateTime.now().year - b.date.year;
      final ageRange = '${(age ~/ 5) * 5}-${((age ~/ 5) * 5) + 4}';
      ageMap[ageRange] = (ageMap[ageRange] ?? 0) + 1;
    }

    // Pie chart data should always use full list
    Map<String, int> groupMap = {};
    for (var b in allBirthdays) {
      final group = b.birthdayGroupId.toString();
      groupMap[group] = (groupMap[group] ?? 0) + 1;
    }

    setState(() {
      birthdaysByMonth = monthMap;
      birthdaysByAgeGroup = ageMap;
      birthdaysByGroup = groupMap;
      isLoading = false;
    });
  }

  Widget buildFilters() {
    final years = allBirthdays.map((b) => b.date.year).toSet().toList()..sort();
    final groupIds = allBirthdays.map((b) => b.birthdayGroupId.toString()).toSet().toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedFromYear,
                  decoration: const InputDecoration(labelText: 'From Year'),
                  items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                  onChanged: (value) {
                    setState(() => selectedFromYear = value);
                    applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedToYear,
                  decoration: const InputDecoration(labelText: 'To Year'),
                  items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                  onChanged: (value) {
                    setState(() => selectedToYear = value);
                    applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: selectedGroupId,
            decoration: const InputDecoration(labelText: 'Filter by Group ID (Bar Charts Only)'),
            items: <DropdownMenuItem<String?>>[
              const DropdownMenuItem(value: null, child: Text("All")),
            ] +
                groupIds
                    .map((id) => DropdownMenuItem(value: id, child: Text("Group $id")))
                    .toList(),
            onChanged: (value) {
              setState(() => selectedGroupId = value);
              applyFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget buildBarChart(Map<String, int> data, String title) {
    final keys = data.keys.toList();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: data.values.isNotEmpty
                      ? data.values.reduce((a, b) => a > b ? a : b).toDouble() + 1
                      : 1,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          if (value.toInt() < keys.length) {
                            return Text(keys[value.toInt()],
                                style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                            toY: entry.value.value.toDouble(), color: Colors.teal)
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPieChart(Map<String, int> data, String title) {
    final total = data.values.fold(0, (sum, value) => sum + value);
    final entries = data.entries.toList();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: PieChart(
                PieChartData(
                  sections: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final e = entry.value;
                    return PieChartSectionData(
                      title: '${e.key} (${e.value})',
                      value: e.value.toDouble(),
                      radius: 60,
                      color: groupColors[index % groupColors.length],
                      titleStyle:
                      const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Statistics Dashboard"),
          backgroundColor: Colors.green),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            buildFilters(),
            buildBarChart(birthdaysByMonth, 'Birthdays by Month'),
            buildBarChart(birthdaysByAgeGroup, 'Birthdays by Age Group'),
            buildPieChart(birthdaysByGroup, 'Birthdays by Group ID'),
          ],
        ),
      ),
    );
  }
}