import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Themes extends ChangeNotifier {
  static bool _isDarkMode = true;
  String _appearanceOption = 'system';
  String get appearanceOption => _appearanceOption;

  bool get isDarkMode => _isDarkMode;

  Themes() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _appearanceOption = prefs.getString('appearance') ?? 'system';
    setAppearance(_appearanceOption);
  }

  Future<void> setAppearance(String value) async {
    _appearanceOption = value;
    setDarkMode(value);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('appearance', value);
  }

  void setDarkMode(String value) {
    _appearanceOption = value;
    if(value == 'system') {
      if(PlatformDispatcher.instance.platformBrightness.name == 'light') {
        _isDarkMode = false;
      } else {
        _isDarkMode = true;
      }
    } else if (value == 'light') {
      _isDarkMode = false;
    } else {
      _isDarkMode = true;
    }
    
    notifyListeners();
  }

  bool systemDarkMode() {
    return PlatformDispatcher.instance.platformBrightness.name == 'dark';
  }

  Color get darkBackgroundColor => Color.fromARGB(255, 44, 44, 44);
  Color get backgroundColor => _isDarkMode ? Color.fromARGB(255, 44, 44, 44) : Colors.white;
  Color get primaryColor => Color.fromARGB(255, 88, 129, 87);
  Color get textColor => _isDarkMode ? Colors.white : Colors.black;

  TextStyle textStyle(BuildContext context) {
    double fontSize = getScaledFontSize(context);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: textColor,
    );
  }

  getScaledFontSize(BuildContext context) {
    const double designTotal = 1276.0;
    double total = MediaQuery.of(context).size.width + MediaQuery.of(context).size.height;
    double scale = total / designTotal;
    return 16 * scale;
  }
}
