import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'country_list.dart';
import 'habit_tracker_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  double _age = 25; // Default age set to 25
  String _country = '';
  List<String> _countries = [];
  List<String> selectedHabits = [];
  List<String> availableHabits = [
    'Wake Up Early',
    'Workout',
    'Drink Water',
    'Meditate',
    'Read a Book',
    'Practice Gratitude',
    'Sleep 8 Hours',
    'Eat Healthy',
    'Journal',
    'Walk 10,000 Steps'
  ];
  final Map<String, Color> _habitColors = {
    'Amber': Colors.amber,
    'Red Accent': Colors.redAccent,
    'Light Blue': Colors.lightBlue,
    'Light Green': Colors.lightGreen,
    'Purple Accent': Colors.purpleAccent,
    'Orange': Colors.orange,
    'Teal': Colors.teal,
    'Deep Purple': Colors.deepPurple,
  };
  @override
  void initState() {
    super.initState();
    _loadCountries();
  }
  Future<void> _loadCountries() async {
    try {
      List<String> countries = await fetchCountries();
      countries.sort(); // Sort countries alphabetically
      setState(() {
        _countries = countries;
        // Set default country to first in sorted list if not set
        if (_country.isEmpty && countries.isNotEmpty) {
          _country = countries.first;
        }
      });
    } catch (e) {
      // Handle error - show more detailed message
      print('Error loading countries: $e');
      _showToast('Error fetching countries. Using default list.');
      // Fallback to a comprehensive list if API fails
      setState(() {
        _countries = [
          'Afghanistan',
          'Albania',
          'Algeria',
          'Argentina',
          'Australia',
          'Austria',
          'Bangladesh',
          'Belgium',
          'Brazil',
          'Canada',
          'Chile',
          'China',
          'Colombia',
          'Denmark',
          'Egypt',
          'Finland',
          'France',
          'Germany',
          'Greece',
          'India',
          'Indonesia',
          'Iran',
          'Ireland',
          'Israel',
          'Italy',
          'Japan',
          'Kenya',
          'Malaysia',
          'Mexico',
          'Netherlands',
          'New Zealand',
          'Nigeria',
          'Norway',
          'Pakistan',
          'Philippines',
          'Poland',
          'Portugal',
          'Russia',
          'Saudi Arabia',
          'Singapore',
          'South Africa',
          'South Korea',
          'Spain',
          'Sweden',
          'Switzerland',
          'Thailand',
          'Turkey',
          'Ukraine',
          'United Arab Emirates',
          'United Kingdom',
          'United States',
          'Vietnam'
        ];
        _countries.sort();
        if (_country.isEmpty) {
          _country = _countries.first;
        }
      });
    }
  }
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  void _register() async {
    final name = _nameController.text;
    final username = _usernameController.text;
    final email = _emailController.text;
    if (username.isEmpty || name.isEmpty || email.isEmpty) {
      _showToast('Please fill in all required fields');
      return;
    }
    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      _showToast('Please enter a valid email address');
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Assign random colors to selected habits.
    Map<String, String> selectedHabitsMap = {};
    final random = Random();
    final colorKeys = _habitColors.keys.toList();
    for (var habit in selectedHabits) {
      var randomColor =
          _habitColors[colorKeys[random.nextInt(colorKeys.length)]]!;
      selectedHabitsMap[habit] = randomColor.value.toRadixString(16);
    }
    // Save user information and habits to shared preferences.
    await prefs.setString('name', name);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setDouble('age', _age);
    await prefs.setString('country', _country);
    await prefs.setString('selectedHabitsMap', jsonEncode(selectedHabitsMap));
    // await prefs.setStringList('selectedHabits', selectedHabits);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HabitTrackerScreen(username: username),
      ),
    );
  }
  void _toggleHabitSelection(String habit) {
    setState(() {
      if (selectedHabits.contains(habit)) {
        selectedHabits.remove(habit);
      } else {
        selectedHabits.add(habit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(
          'Register',
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(_nameController, 'Name', Icons.person),
                SizedBox(height: 10),
                _buildInputField(
                    _usernameController, 'Username', Icons.alternate_email),
                SizedBox(height: 10),
                _buildInputField(
                    _emailController, 'Email', Icons.email),
                SizedBox(height: 10),
                Text('Age: ${_age.round()}',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Slider(
                  value: _age,
                  min: 21,
                  max: 100,
                  divisions: 79,
                  activeColor: Colors.green.shade600,
                  inactiveColor: Colors.green.shade300,
                  onChanged: (double value) {
                    setState(() {
                      _age = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                _buildCountryDropdown(),
                SizedBox(height: 10),
                Text('Select Your Habits',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: availableHabits.map((habit) {
                    final isSelected = selectedHabits.contains(habit);
                    return GestureDetector(
                      onTap: () => _toggleHabitSelection(habit),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                          isSelected ? Colors.green.shade600 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade700),
                        ),
                        child: Text(
                          habit,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    // Ensure _country is valid or set to first country if list is available
    String? currentValue = _country.isNotEmpty && _countries.contains(_country)
        ? _country
        : (_countries.isNotEmpty ? _countries.first : null);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: _countries.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Loading countries...',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : DropdownButton<String>(
              value: currentValue,
              icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade700),
              isExpanded: true,
              underline: SizedBox(),
              items: _countries.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _country = newValue!;
                });
              },
            ),
    );
  }
}