import 'package:flutter/foundation.dart';
import '../models/debt.dart';
import '../services/simple_sync_service.dart';
import '../services/device_service.dart';

class DebtProvider with ChangeNotifier {
  
  List<Debt> _debts = [];
  bool _isLoading = false;
  String? _error;
  String? _deviceId;

  List<Debt> get debts => _debts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get deviceId => _deviceId;

  // Filtered debts
  List<Debt> _filteredDebts = [];
  List<Debt> get filteredDebts => _filteredDebts;

  // Search and filter state
  String _searchQuery = '';
  DebtStatus? _statusFilter;
  String _sortBy = 'date';
  bool _sortAscending = false;

  String get searchQuery => _searchQuery;
  DebtStatus? get statusFilter => _statusFilter;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  Future<void> initialize() async {
    _deviceId = await DeviceService.getDeviceId();
    await loadDebts();
  }

  Future<void> loadDebts() async {
    _setLoading(true);
    try {
      _debts = await SimpleSyncService.getAllDebts();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to load debts: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<Debt> addDebt(Debt debt) async {
    try {
      await SimpleSyncService.createDebt(debt);
      _debts.insert(0, debt);
      _applyFilters();
      notifyListeners();
      return debt;
    } catch (e) {
      _error = 'Failed to add debt: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<Debt> updateDebt(Debt debt) async {
    try {
      await SimpleSyncService.updateDebt(debt);
      final index = _debts.indexWhere((d) => d.id == debt.id);
      if (index != -1) {
        _debts[index] = debt;
        _applyFilters();
        notifyListeners();
      }
      return debt;
    } catch (e) {
      _error = 'Failed to update debt: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteDebt(String id) async {
    try {
      await SimpleSyncService.deleteDebt(id);
      _debts.removeWhere((debt) => debt.id == id);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete debt: $e';
      notifyListeners();
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(DebtStatus? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void setSorting(String sortBy, bool ascending) {
    _sortBy = sortBy;
    _sortAscending = ascending;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredDebts = List.from(_debts);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredDebts = _filteredDebts.where((debt) {
        return debt.debtorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (debt.debtorEmail?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (debt.debtorPhone?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      _filteredDebts = _filteredDebts.where((debt) => debt.status == _statusFilter).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'amount':
        _filteredDebts.sort((a, b) => _sortAscending 
            ? a.amount.compareTo(b.amount) 
            : b.amount.compareTo(a.amount));
        break;
      case 'name':
        _filteredDebts.sort((a, b) => _sortAscending 
            ? a.debtorName.compareTo(b.debtorName) 
            : b.debtorName.compareTo(a.debtorName));
        break;
      case 'date':
      default:
        _filteredDebts.sort((a, b) => _sortAscending 
            ? a.createdAt.compareTo(b.createdAt) 
            : b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    // Calculate analytics from local data
    final totalAmount = getTotalAmount();
    final activeAmount = getActiveAmount();
    final settledAmount = getSettledAmount();
    final activeCount = getActiveDebts().length;
    final settledCount = getSettledDebts().length;
    final overdueCount = getOverdueDebts().length;
    
    return {
      'totalAmount': totalAmount,
      'activeCount': activeCount,
      'settledCount': settledCount,
      'overdueCount': overdueCount,
      'totalCount': _debts.length,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get debts by status
  List<Debt> getActiveDebts() {
    return _debts.where((debt) => debt.status == DebtStatus.active).toList();
  }

  List<Debt> getSettledDebts() {
    return _debts.where((debt) => debt.status == DebtStatus.settled).toList();
  }

  List<Debt> getOverdueDebts() {
    return _debts.where((debt) => debt.status == DebtStatus.overdue).toList();
  }

  // Calculate totals
  double getTotalAmount() {
    return _debts.fold(0.0, (sum, debt) => sum + debt.amount);
  }

  double getActiveAmount() {
    return getActiveDebts().fold(0.0, (sum, debt) => sum + debt.amount);
  }

  double getSettledAmount() {
    return getSettledDebts().fold(0.0, (sum, debt) => sum + debt.amount);
  }
}
