import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/bmi_record.dart';

enum SortField { name, age, bmi, dateAdded }

class UserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches patients applying search (case-insensitive partial match on
  /// name), gender/category filters, and sort — all resolved server-side
  /// where possible. Sorting/filtering never mutates underlying data.
  Future<List<BmiRecord>> fetchPatients({
    String? searchQuery,
    String? genderFilter, // 'Male' | 'Female' | 'Other' | null = all
    String? categoryFilter, // BMI category | null = all
    SortField sortField = SortField.dateAdded,
    bool ascending = false,
  }) async {
    var query = _client.from(AppConstants.tablePatients).select();

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('name', '%${searchQuery.trim()}%');
    }
    if (genderFilter != null && genderFilter != 'All') {
      query = query.eq('gender', genderFilter);
    }
    if (categoryFilter != null && categoryFilter != 'All') {
      query = query.eq('bmi_category', categoryFilter);
    }

    final column = switch (sortField) {
      SortField.name => 'name',
      SortField.age => 'age',
      SortField.bmi => 'bmi',
      SortField.dateAdded => 'created_at',
    };

    final data = await query.order(column, ascending: ascending);
    return (data as List).map((e) => BmiRecord.fromMap(e)).toList();
  }

  Future<BmiRecord> fetchById(String id) async {
    final data = await _client
        .from(AppConstants.tablePatients)
        .select()
        .eq('id', id)
        .single();
    return BmiRecord.fromMap(data);
  }

  Future<BmiRecord> createPatient(
      Map<String, dynamic> insertMap) async {
    final data = await _client
        .from(AppConstants.tablePatients)
        .insert(insertMap)
        .select()
        .single();
    return BmiRecord.fromMap(data);
  }

  Future<BmiRecord> updatePatient(
      String id, Map<String, dynamic> updateMap) async {
    final data = await _client
        .from(AppConstants.tablePatients)
        .update(updateMap)
        .eq('id', id)
        .select()
        .single();
    return BmiRecord.fromMap(data);
  }

  /// Admin-only at the UI layer — but the real restriction is enforced
  /// by the `patients_delete_admin_only` RLS policy in Postgres.
  Future<void> deletePatient(String id) async {
    await _client.from(AppConstants.tablePatients).delete().eq('id', id);
  }

  Future<int> countAll() async {
    final data =
        await _client.from(AppConstants.tablePatients).select('id');
    return (data as List).length;
  }
}
