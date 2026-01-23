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
    String userId,
    String startDate,
    String endDate,
  ) async {
    try {
      final response = await _client
          .from('time_entries')
          .select()
          .eq('user_id', userId)
          .gte(
            'created_at',
            startDate,
          ) // Greater than or equal (Maior ou igual)
          .lte('created_at', endDate) // Less than or equal (Menor ou igual)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPunchesByCustomRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final response = await _client
        .from('time_entries')
        .select()
        .eq('user_id', userId)
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String())
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchBalanceForMonth(
    String userId,
    DateTime month,
  ) async {
    // Formata para '2025-12-01' para bater com o tipo DATE do banco
    final String monthDate =
        "${month.year}-${month.month.toString().padLeft(2, '0')}-01";

    final response = await _client
        .from('monthly_balances')
        .select()
        .eq('user_id', userId)
        .eq('month_year', monthDate) // Ajuste para o nome da coluna no banco
        .maybeSingle(); // Retorna um Map ou null se não houver fechamento

    return response;
    
  }

  // No seu Repository
  Future<void> upsertMonthlyBalance({
    required String userId,
    required DateTime month,
    required double balance,
  }) async {
    // Formata para o primeiro dia do mês: YYYY-MM-01
    final String monthDate =
        "${month.year}-${month.month.toString().padLeft(2, '0')}-01";

    await _client.from('monthly_balances').upsert({
      'user_id': userId,
      'month_year': monthDate, // Nome da coluna que criamos no SQL
      'balance_hours': balance,
    }, onConflict: 'user_id, month_year'); // Chave única para evitar duplicados
  }
}
