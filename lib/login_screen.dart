import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'habit_tracker_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Default credentials
  final String defaultUsername = 'dave';
  final String defaultEmail = 'dave@example.com';
  final String defaultPassword = '12345';

  void _login() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Check if at least username or email is provided
    if (username.isEmpty && email.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter either username or email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    
    // Check password is provided
    if (password.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    
    bool loginSuccessful = false;
    String? loggedInUsername;
    
    // Check against default credentials (username OR email)
    if (password == defaultPassword) {
      if ((username.isNotEmpty && username == defaultUsername) ||
          (email.isNotEmpty && email == defaultEmail)) {
        await prefs.setString('name', 'Dave');
        await prefs.setString('username', 'dave');
        await prefs.setString('email', 'dave@example.com');
        await prefs.setDouble('age', 25);
        await prefs.setString('country', 'United States');
        loggedInUsername = defaultUsername;
        loginSuccessful = true;
      }
    }
    
    // If not default user, check against stored user data
    if (!loginSuccessful) {
      String? storedUsername = prefs.getString('username');
      String? storedEmail = prefs.getString('email');
      
      // Check if provided username or email matches stored data
      bool usernameMatches = username.isNotEmpty && 
          storedUsername != null && 
          username.toLowerCase() == storedUsername.toLowerCase();
      bool emailMatches = email.isNotEmpty && 
          storedEmail != null && 
          email.toLowerCase() == storedEmail.toLowerCase();
      
      // For stored users, we'd need to check password from storage
      // For now, if username/email matches, we'll allow login
      // (In a real app, you'd verify password from secure storage)
      if ((usernameMatches || emailMatches)) {
        loggedInUsername = storedUsername ?? username;
        loginSuccessful = true;
      }
    }
    
    if (loginSuccessful && loggedInUsername != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HabitTrackerScreen(username: loggedInUsername!),
        ),
      );
    } else {
      // Clear shared preferences on failed login
      await prefs.clear();
      Fluttertoast.showToast(
        msg: "The username, email or password was incorrect",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Habittastic',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon:
                          Icon(Icons.person, color: Colors.green.shade700),
                      hintText: 'Username',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon:
                          Icon(Icons.email, color: Colors.green.shade700),
                      hintText: 'Email',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.green.shade700),
                      hintText: 'Enter Password',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Logic for forgot password can be added here
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  ),
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'or',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                  ),
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () {
                        // Already on login page, so this could scroll to top or do nothing
                        // Or navigate to login if coming from elsewhere
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
