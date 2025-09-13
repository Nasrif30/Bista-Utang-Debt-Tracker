import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/debt.dart';

class LocalStorageService {
  static const String _debtsKey = 'debts';
  static const String _lastSyncKey = 'last_sync';
  static const String _pendingSyncKey = 'pending_sync';

  // Save debts to local storage
  static Future<void> saveDebts(List<Debt> debts) async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = debts.map((debt) => debt.toJson()).toList();
    await prefs.setString(_debtsKey, jsonEncode(debtsJson));
  }

  // Load debts from local storage
  static Future<List<Debt>> loadDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtsString = prefs.getString(_debtsKey);
    
    if (debtsString == null) {
      return [];
    }
    
    try {
      final List<dynamic> debtsJson = jsonDecode(debtsString);
      return debtsJson.map((json) => Debt.fromJson(json)).toList();
    } catch (e) {
      print('Error loading debts from local storage: $e');
      return [];
    }
  }

  // Add a single debt
  static Future<void> addDebt(Debt debt) async {
    final debts = await loadDebts();
    // Ensure debt has an ID
    final debtWithId = debt.id != null ? debt : debt.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
    debts.add(debtWithId);
    await saveDebts(debts);
  }

  // Update a debt
  static Future<void> updateDebt(Debt updatedDebt) async {
    final debts = await loadDebts();
    final index = debts.indexWhere((debt) => debt.id == updatedDebt.id);
    if (index != -1) {
      debts[index] = updatedDebt;
      await saveDebts(debts);
    }
  }

  // Delete a debt
  static Future<void> deleteDebt(String debtId) async {
    final debts = await loadDebts();
    debts.removeWhere((debt) => debt.id == debtId);
    await saveDebts(debts);
  }

  // Get a single debt by ID
  static Future<Debt?> getDebt(String id) async {
    final debts = await loadDebts();
    try {
      return debts.firstWhere((debt) => debt.id == id);
    } catch (e) {
      return null;
    }
  }

  // Save last sync timestamp
  static Future<void> saveLastSync(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, timestamp.toIso8601String());
  }

  // Get last sync timestamp
  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampString = prefs.getString(_lastSyncKey);
    if (timestampString != null) {
      try {
        return DateTime.parse(timestampString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Save pending sync operations
  static Future<void> savePendingSync(List<Map<String, dynamic>> operations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingSyncKey, jsonEncode(operations));
  }

  // Get pending sync operations
  static Future<List<Map<String, dynamic>>> getPendingSync() async {
    final prefs = await SharedPreferences.getInstance();
    final operationsString = prefs.getString(_pendingSyncKey);
    
    if (operationsString == null) {
      return [];
    }
    
    try {
      final List<dynamic> operationsJson = jsonDecode(operationsString);
      return operationsJson.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading pending sync operations: $e');
      return [];
    }
  }

  // Clear pending sync operations
  static Future<void> clearPendingSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingSyncKey);
  }

  // Add operation to pending sync
  static Future<void> addPendingSync(String operation, Debt debt) async {
    final pendingOps = await getPendingSync();
    pendingOps.add({
      'operation': operation,
      'debt': debt.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    await savePendingSync(pendingOps);
  }

  // Clear all local data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_debtsKey);
    await prefs.remove(_lastSyncKey);
    await prefs.remove(_pendingSyncKey);
  }
}
