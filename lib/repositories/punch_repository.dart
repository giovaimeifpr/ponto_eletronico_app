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
  
 
  Future<List<Map<String, dynamic>>> fetchPunchesByDateRange(
      String userId, String startDate, String endDate) async {
    try {
      final response = await _client
          .from('time_entries')
          .select()
          .eq('user_id', userId)
          .gte('created_at', startDate) // Greater than or equal (Maior ou igual)
          .lte('created_at', endDate)   // Less than or equal (Menor ou igual)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
}