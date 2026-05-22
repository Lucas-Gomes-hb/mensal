import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/month_data.dart';

class StorageService {
  static String _key(int year, int month) =>
      'month_${year}_${month.toString().padLeft(2, '0')}';

  Future<List<MonthData>> loadMonthCalculations(int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(year, month));
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded
          .map((e) => MonthData.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Legacy single-object format — migrate transparently
    return [MonthData.fromJson(decoded as Map<String, dynamic>)];
  }

  Future<void> saveMonthCalculations(
      int year, int month, List<MonthData> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(year, month),
      jsonEncode(data.map((e) => e.toJson()).toList()),
    );
  }

  Future<bool> hasMonth(int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key(year, month));
  }
}
