import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInProvider extends ChangeNotifier {
  List<DateTime> _signIns = [];
  static const String _storageKey = 'signin_records';

  List<DateTime> get signIns => _signIns;

  SignInProvider() {
    _loadSignIns();
  }

  Future<void> _loadSignIns() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedList = prefs.getStringList(_storageKey);

    if (storedList != null) {
      _signIns = storedList.map((e) => DateTime.parse(e)).toList();
      _signIns.sort(); // Keep them sorted
      notifyListeners();
    }
  }

  Future<void> addSignIn() async {
    final now = DateTime.now();
    _signIns.add(now);
    _signIns.sort();
    notifyListeners();
    await _saveSignIns();
  }

  Future<void> deleteSignIn(DateTime timestamp) async {
    _signIns.remove(timestamp);
    notifyListeners();
    await _saveSignIns();
  }

  Future<void> _saveSignIns() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stringList = _signIns
        .map((e) => e.toIso8601String())
        .toList();
    await prefs.setStringList(_storageKey, stringList);
  }

  Future<void> clearData() async {
    _signIns.clear();
    notifyListeners();
    await _saveSignIns();
  }

  String exportData() {
    final List<String> stringList = _signIns
        .map((e) => e.toIso8601String())
        .toList();
    return jsonEncode(stringList);
  }

  Future<bool> importData(String jsonString) async {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final List<DateTime> newSignIns = decoded
          .map((e) => DateTime.parse(e.toString()))
          .toList();

      // Merge or Replace? Let's merge for safety, avoiding duplicates
      for (var date in newSignIns) {
        if (!_signIns.any((existing) => existing.isAtSameMomentAs(date))) {
          _signIns.add(date);
        }
      }
      _signIns.sort();
      notifyListeners();
      await _saveSignIns();
      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  List<DateTime> getSignInsForDay(DateTime day) {
    return _signIns
        .where(
          (date) =>
              date.year == day.year &&
              date.month == day.month &&
              date.day == day.day,
        )
        .toList();
  }

  int getCountForDay(DateTime day) {
    return getSignInsForDay(day).length;
  }

  Map<int, int> getYearlyStats(int year) {
    // Returns a map of Month (1-12) -> Count
    final Map<int, int> stats = {};
    for (int i = 1; i <= 12; i++) {
      stats[i] = 0;
    }

    for (var date in _signIns) {
      if (date.year == year) {
        stats[date.month] = (stats[date.month] ?? 0) + 1;
      }
    }
    return stats;
  }
}
