import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/debt.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://sraosuzmsncrsegmzgik.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyYW9zdXptc25jcnNlZ216Z2lrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1Mjk5MjcsImV4cCI6MjA3MzEwNTkyN30.X2uNYzGAJVnqpIhcKwT2DAX5y6HpV__IwfXs4DNv7IU';

  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }

  // Authentication methods (simplified for no-auth app)
  static Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      await client.auth.signOut();
    }
  }

  static User? get currentUser {
    final client = _client;
    return client?.auth.currentUser;
  }

  // Debt CRUD operations (with null safety)
  static Future<List<Debt>> getDebts({String? userId}) async {
    final client = _client;
    if (client == null) {
      return []; // Return empty list if Supabase not initialized
    }
    
    try {
      final query = client
          .from('debts')
          .select()
          .eq('user_id', userId ?? currentUser?.id ?? '')
          .order('created_at', ascending: false);

      final response = await query;
      return (response as List).map((json) => Debt.fromJson(json)).toList();
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  static Future<Debt?> getDebt(String id) async {
    final client = _client;
    if (client == null) return null;
    
    try {
      final response = await client
          .from('debts')
          .select()
          .eq('id', id)
          .single();

      return response != null ? Debt.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  static Future<Debt> createDebt(Debt debt) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not initialized');
    }
    
    try {
      // Generate a UUID for the debt if it doesn't have one
      final debtData = debt.toJson();
      if (debtData['id'] == null) {
        debtData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }
      
      final response = await client
          .from('debts')
          .insert(debtData)
          .select()
          .single();

      return Debt.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create debt: $e');
    }
  }

  static Future<Debt> updateDebt(Debt debt) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not initialized');
    }
    
    try {
      final response = await client
          .from('debts')
          .update(debt.toJson())
          .eq('id', debt.id!)
          .select()
          .single();

      return Debt.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update debt: $e');
    }
  }

  static Future<void> deleteDebt(String id) async {
    final client = _client;
    if (client == null) return;
    
    try {
      await client.from('debts').delete().eq('id', id);
    } catch (e) {
      // Silently fail for now
    }
  }

  // Search and filter methods (simplified)
  static Future<List<Debt>> searchDebts({
    required String userId,
    String? query,
    DebtStatus? status,
    String? sortBy,
    bool ascending = false,
  }) async {
    // For now, just return all debts - we'll use local database for search/filter
    return await getDebts(userId: userId);
  }

  // Analytics methods
  static Future<Map<String, dynamic>> getDebtAnalytics(String userId) async {
    final client = _client;
    if (client == null) {
      return {
        'totalAmount': 0.0,
        'activeCount': 0,
        'settledCount': 0,
        'overdueCount': 0,
        'totalCount': 0,
      };
    }
    
    try {
      final response = await client
          .from('debts')
          .select('amount, status')
          .eq('user_id', userId);

      final debts = (response as List).map((json) => Debt.fromJson(json)).toList();

      double totalAmount = 0;
      int activeCount = 0;
      int settledCount = 0;
      int overdueCount = 0;

      for (final debt in debts) {
        totalAmount += debt.amount;
        switch (debt.status) {
          case DebtStatus.active:
            activeCount++;
            break;
          case DebtStatus.settled:
            settledCount++;
            break;
          case DebtStatus.overdue:
            overdueCount++;
            break;
        }
      }

      return {
        'totalAmount': totalAmount,
        'activeCount': activeCount,
        'settledCount': settledCount,
        'overdueCount': overdueCount,
        'totalCount': debts.length,
      };
    } catch (e) {
      return {
        'totalAmount': 0.0,
        'activeCount': 0,
        'settledCount': 0,
        'overdueCount': 0,
        'totalCount': 0,
      };
    }
  }
}