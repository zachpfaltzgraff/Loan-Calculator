import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class Vibrator extends ChangeNotifier {
  static bool _vibrate = true;

  bool get vibrate => _vibrate;

  Vibrator() {
    _loadFromPrefs();
  }

  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _vibrate = prefs.getBool('vibrate') ?? true;
    notifyListeners();
  }

  Future<bool> canVibrate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibrate') ?? true;
  }

  Future<void> vibrateShort() async {
    if(!await canVibrate()) return;

    Vibration.vibrate(duration: 25, amplitude: 75);
  }

  Future<void> toggleVibrate() async {
    _vibrate = !_vibrate;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('vibrate', _vibrate);
  }

  void setVibrate(bool value) {
    _vibrate = value;
  }
}