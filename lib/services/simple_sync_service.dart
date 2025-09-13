import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/debt.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';

class SimpleSyncService {
  static Timer? _syncTimer;
  static bool _isOnline = false;
  static final Connectivity _connectivity = Connectivity();

  static Future<void> initialize() async {
    // Check initial connectivity
    _isOnline = await _checkConnectivity();
    
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _startPeriodicSync();
        _syncPendingChanges();
      } else {
        _stopPeriodicSync();
      }
    });

    // Start periodic sync if online
    if (_isOnline) {
      _startPeriodicSync();
      _syncPendingChanges();
    }
  }

  static Future<bool> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static void _startPeriodicSync() {
    _stopPeriodicSync(); // Stop any existing timer
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _syncPendingChanges();
    });
  }

  static void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  static Future<void> _syncPendingChanges() async {
    if (!_isOnline) return;

    try {
      final pendingOps = await LocalStorageService.getPendingSync();
      
      for (final op in pendingOps) {
        final operation = op['operation'] as String;
        final debtData = op['debt'] as Map<String, dynamic>;
        final debt = Debt.fromJson(debtData);
        
        try {
          switch (operation) {
            case 'create':
              await SupabaseService.createDebt(debt);
              break;
            case 'update':
              await SupabaseService.updateDebt(debt);
              break;
            case 'delete':
              await SupabaseService.deleteDebt(debt.id!);
              break;
          }
        } catch (e) {
          print('Failed to sync $operation for debt ${debt.id}: $e');
          // Keep in queue for retry
        }
      }
      
      // Clear successfully synced items
      await LocalStorageService.clearPendingSync();
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  // Public methods for debt operations
  static Future<void> createDebt(Debt debt) async {
    // Always save locally first
    await LocalStorageService.addDebt(debt);
    
    if (_isOnline) {
      try {
        await SupabaseService.createDebt(debt);
        await LocalStorageService.saveLastSync(DateTime.now());
      } catch (e) {
        // Add to sync queue for later
        await LocalStorageService.addPendingSync('create', debt);
      }
    } else {
      // Add to sync queue for when online
      await LocalStorageService.addPendingSync('create', debt);
    }
  }

  static Future<void> updateDebt(Debt debt) async {
    // Always update locally first
    await LocalStorageService.updateDebt(debt);
    
    if (_isOnline) {
      try {
        await SupabaseService.updateDebt(debt);
        await LocalStorageService.saveLastSync(DateTime.now());
      } catch (e) {
        // Add to sync queue for later
        await LocalStorageService.addPendingSync('update', debt);
      }
    } else {
      // Add to sync queue for when online
      await LocalStorageService.addPendingSync('update', debt);
    }
  }

  static Future<void> deleteDebt(String debtId) async {
    // Always delete locally first
    await LocalStorageService.deleteDebt(debtId);
    
    if (_isOnline) {
      try {
        await SupabaseService.deleteDebt(debtId);
        await LocalStorageService.saveLastSync(DateTime.now());
      } catch (e) {
        // Add to sync queue for later
        final debt = await LocalStorageService.getDebt(debtId);
        if (debt != null) {
          await LocalStorageService.addPendingSync('delete', debt);
        }
      }
    } else {
      // Add to sync queue for when online
      final debt = await LocalStorageService.getDebt(debtId);
      if (debt != null) {
        await LocalStorageService.addPendingSync('delete', debt);
      }
    }
  }

  static Future<List<Debt>> getAllDebts() async {
    // Always return local data for immediate response
    return await LocalStorageService.loadDebts();
  }

  static Future<Debt?> getDebt(String id) async {
    return await LocalStorageService.getDebt(id);
  }

  // Manual sync trigger
  static Future<void> forceSync() async {
    if (_isOnline) {
      await _syncPendingChanges();
    }
  }

  // Check if online
  static bool get isOnline => _isOnline;

  // Sync from cloud to local (for initial load)
  static Future<void> syncFromCloud() async {
    if (!_isOnline) return;

    try {
      final cloudDebts = await SupabaseService.getDebts();
      await LocalStorageService.saveDebts(cloudDebts);
      await LocalStorageService.saveLastSync(DateTime.now());
    } catch (e) {
      print('Failed to sync from cloud: $e');
    }
  }
}
