import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, List<int>> weeklyData = {};
  List<String> selectedHabits = [];
  final List<String> daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get all habits (selected + completed) from the maps
    Map<String, String> allHabitsMap = {};
    
    String? selectedHabitsMapString = prefs.getString('selectedHabitsMap');
    if (selectedHabitsMapString != null) {
      Map<String, dynamic> selectedHabitsMap = jsonDecode(selectedHabitsMapString);
      allHabitsMap.addAll(Map<String, String>.from(selectedHabitsMap));
    }
    
    String? completedHabitsMapString = prefs.getString('completedHabitsMap');
    if (completedHabitsMapString != null) {
      Map<String, dynamic> completedHabitsMap = jsonDecode(completedHabitsMapString);
      allHabitsMap.addAll(Map<String, String>.from(completedHabitsMap));
    }
    
    selectedHabits = allHabitsMap.keys.toList();

    // If no habits exist, reset weeklyData
    if (selectedHabits.isEmpty) {
      setState(() {
        weeklyData = {};
      });
      return;
    }

    // Load the data from shared preferences or initialize with zeros if none exists
    String? storedData = prefs.getString('weeklyData');
    if (storedData == null) {
      // Initialize with all zeros (no completions yet)
      Map<String, List<int>> initialData = {
        for (var habit in selectedHabits)
          habit: List.filled(7, 0), // All zeros initially
      };
      await prefs.setString('weeklyData', jsonEncode(initialData));
      storedData = jsonEncode(initialData);
    }

    // Decode and set weekly data (storedData is guaranteed to be non-null here)
    String dataToDecode = storedData;
    Map<String, dynamic> decodedData = jsonDecode(dataToDecode);
    Map<String, List<int>> loadedData = decodedData.map((key, value) => MapEntry(
      key,
      List<int>.from(value),
    ));
    
    // Ensure all current habits have weekly data entries
    for (var habit in selectedHabits) {
      if (!loadedData.containsKey(habit)) {
        loadedData[habit] = List.filled(7, 0);
      }
    }
    
    setState(() {
      weeklyData = loadedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text(
          'Weekly Report',
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: weeklyData.isEmpty
          ? const Center(
              child: Text(
                'No data available. Please configure habits first.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: _buildColumns(),
                  rows: _buildRows(),
                ),
              ),
            ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(
        label: Text('Habit', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      ...daysOfWeek.map((day) => DataColumn(
            label: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
    ];
  }

  List<DataRow> _buildRows() {
    return selectedHabits.map((habit) {
      return DataRow(
        cells: [
          DataCell(Text(habit)),
          ...List.generate(7, (index) {
            bool isCompleted = weeklyData[habit]?[index] == 1;
            return DataCell(
              Icon(
                isCompleted ? Icons.check_circle : Icons.cancel,
                color: isCompleted ? Colors.green : Colors.red,
              ),
            );
          }),
        ],
      );
    }).toList();
  }
}