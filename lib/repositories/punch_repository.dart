import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

class PunchRepository {
  final _client = Supabase.instance.client;

  Future<void> insertPunch({
    required String userId,
    required double lat,
    required double lon,
    required String type,
    required int distance,
  }) async {
    await _client.from(AppConstants.tableTimeEntries).insert({
      'user_id': userId,
      'device_lat': lat,
      'device_lon': lon,
      'entry_type': type,
      'distance_meters': distance,
    });
  }
  
  Future<bool> checkExistingPunchToday({
    required String userId,
    required String type,
  }) async {
    // Pega o início e o fim do dia atual no formato ISO
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final response = await _client
        .from('time_entries')
        .select()
        .eq('user_id', userId)
        .eq('entry_type', type)
        .gte('created_at', startOfDay) // Maior ou igual ao início do dia
        .lte('created_at', endOfDay)   // Menor ou igual ao fim do dia
        .maybeSingle();

    return response != null; // Retorna true se encontrou algo
  }

    Future<List<Map<String, dynamic>>> getTodayPunches(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final response = await _client
        .from('time_entries')
        .select()
        .eq('user_id', userId)
        .gte('created_at', startOfDay)
        .lte('created_at', endOfDay)
        .order('created_at', ascending: true); // Ordena do primeiro ao último ponto

    return List<Map<String, dynamic>>.from(response);
  }
}