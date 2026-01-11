import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class for managing local storage using SharedPreferences
/// This follows the pattern of saving and retrieving user profile data as JSON
class StorageService {
  // Function to save user profile data
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userProfile', jsonEncode(profile));
    } catch (error) {
      print('Error saving user profile: $error');
    }
  }

  // Function to retrieve user profile data
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString('userProfile');
      return profileString != null ? jsonDecode(profileString) : null;
    } catch (error) {
      print('Error fetching user profile: $error');
      return null;
    }
  }

  // Helper function to save individual user fields (for backward compatibility)
  static Future<void> saveUserData({
    String? name,
    String? username,
    double? age,
    String? country,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing profile or create new one
      Map<String, dynamic> profile = await getUserProfile() ?? {};
      
      // Update profile with new values
      if (name != null) profile['name'] = name;
      if (username != null) profile['username'] = username;
      if (age != null) profile['age'] = age;
      if (country != null) profile['country'] = country;
      
      // Save updated profile
      await saveUserProfile(profile);
      
      // Also save individual fields for backward compatibility
      if (name != null) await prefs.setString('name', name);
      if (username != null) await prefs.setString('username', username);
      if (age != null) await prefs.setDouble('age', age);
      if (country != null) await prefs.setString('country', country);
    } catch (error) {
      print('Error saving user data: $error');
    }
  }

  // Helper function to get individual user fields (for backward compatibility)
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to get from profile first
      Map<String, dynamic>? profile = await getUserProfile();
      if (profile != null && profile.isNotEmpty) {
        return profile;
      }
      
      // Fall back to individual fields
      return {
        'name': prefs.getString('name') ?? '',
        'username': prefs.getString('username') ?? '',
        'age': prefs.getDouble('age') ?? 25,
        'country': prefs.getString('country') ?? 'United States',
      };
    } catch (error) {
      print('Error fetching user data: $error');
      return {
        'name': '',
        'username': '',
        'age': 25,
        'country': 'United States',
      };
    }
  }

  // ========== User Actions Storage ==========
  // Function to save user action (following the example pattern)
  static Future<void> saveUserAction(String action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> actions = prefs.getStringList('userActions') ?? [];
      actions.add(action);
      await prefs.setStringList('userActions', actions);
    } catch (error) {
      print('Error saving user action: $error');
    }
  }

  // Function to retrieve all user actions
  static Future<List<String>> getUserActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('userActions') ?? [];
    } catch (error) {
      print('Error fetching user actions: $error');
      return [];
    }
  }

  // Function to clear all user actions
  static Future<void> clearUserActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userActions');
    } catch (error) {
      print('Error clearing user actions: $error');
    }
  }

  // ========== Habits Storage ==========
  // Function to save habits (selected and completed)
  static Future<void> saveHabits({
    Map<String, String>? selectedHabitsMap,
    Map<String, String>? completedHabitsMap,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (selectedHabitsMap != null) {
        await prefs.setString('selectedHabitsMap', jsonEncode(selectedHabitsMap));
      }
      if (completedHabitsMap != null) {
        await prefs.setString('completedHabitsMap', jsonEncode(completedHabitsMap));
      }
    } catch (error) {
      print('Error saving habits: $error');
    }
  }

  // Function to retrieve habits
  static Future<Map<String, Map<String, String>>> getHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, String> selectedHabitsMap = Map<String, String>.from(
          jsonDecode(prefs.getString('selectedHabitsMap') ?? '{}'));
      Map<String, String> completedHabitsMap = Map<String, String>.from(
          jsonDecode(prefs.getString('completedHabitsMap') ?? '{}'));
      
      return {
        'selected': selectedHabitsMap,
        'completed': completedHabitsMap,
      };
    } catch (error) {
      print('Error fetching habits: $error');
      return {
        'selected': <String, String>{},
        'completed': <String, String>{},
      };
    }
  }

  // ========== Notifications Storage ==========
  // Function to save notification settings
  static Future<void> saveNotificationSettings({
    bool? enabled,
    List<String>? selectedHabits,
    List<String>? selectedTimes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (enabled != null) {
        await prefs.setBool('notificationsEnabled', enabled);
      }
      if (selectedHabits != null) {
        await prefs.setStringList('notificationHabits', selectedHabits);
      }
      if (selectedTimes != null) {
        await prefs.setStringList('notificationTimes', selectedTimes);
      }
    } catch (error) {
      print('Error saving notification settings: $error');
    }
  }

  // Function to retrieve notification settings
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'enabled': prefs.getBool('notificationsEnabled') ?? false,
        'selectedHabits': prefs.getStringList('notificationHabits') ?? [],
        'selectedTimes': prefs.getStringList('notificationTimes') ?? [],
      };
    } catch (error) {
      print('Error fetching notification settings: $error');
      return {
        'enabled': false,
        'selectedHabits': <String>[],
        'selectedTimes': <String>[],
      };
    }
  }

  // ========== Weekly Data Storage ==========
  // Function to save weekly habit data
  static Future<void> saveWeeklyData(Map<String, List<int>> weeklyData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weeklyData', jsonEncode(weeklyData));
    } catch (error) {
      print('Error saving weekly data: $error');
    }
  }

  // Function to retrieve weekly habit data
  static Future<Map<String, List<int>>> getWeeklyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedData = prefs.getString('weeklyData');
      if (storedData != null) {
        Map<String, dynamic> decoded = jsonDecode(storedData);
        return decoded.map((key, value) => 
          MapEntry(key, List<int>.from(value)));
      }
      return {};
    } catch (error) {
      print('Error fetching weekly data: $error');
      return {};
    }
  }

  // ========== General Utility Functions ==========
  // Function to clear all app data
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (error) {
      print('Error clearing all data: $error');
    }
  }

  // Function to clear specific data type
  static Future<void> clearData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (error) {
      print('Error clearing data for key $key: $error');
    }
  }
}

