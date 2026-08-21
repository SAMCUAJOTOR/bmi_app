import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/bmi_history.dart';

class BmiRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> addHistoryEntry(Map<String, dynamic> insertMap) async {
    await _client.from(AppConstants.tableBmiHistory).insert(insertMap);
  }

  Future<List<BmiHistory>> fetchHistoryForUser(String userId) async {
    final data = await _client
        .from(AppConstants.tableBmiHistory)
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: true);
    return (data as List).map((e) => BmiHistory.fromMap(e)).toList();
  }

  /// Pulls all history joined with patient info for reporting/export.
  Future<List<Map<String, dynamic>>> fetchAllWithPatientInfo() async {
    final data = await _client
        .from(AppConstants.tablePatients)
        .select('*, bmi_history(*)');
    return (data as List).cast<Map<String, dynamic>>();
  }
}
