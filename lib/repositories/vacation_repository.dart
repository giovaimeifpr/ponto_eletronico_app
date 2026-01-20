import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

class VacationRepository {
  final _client = Supabase.instance.client;

  // 1. Busca férias apenas do usuário logado (Colaborador)
  Future<List<Map<String, dynamic>>> fetchUserVacations(String userId) async {
    try {
      final response = await _client
          .from(AppConstants.tableVacations)
          .select()
          .eq('user_id', userId) // Filtro essencial
          .order('start_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // 2. Método para inserir nova solicitação de férias
  Future<void> requestVacation(Map<String, dynamic> vacationData) async {
    try {
      await _client
          .from(AppConstants.tableVacations)
          .insert(vacationData);
    } catch (e) {
      rethrow;
    }
  }

  // 3. Método para o Admin buscar todas as solicitações pendentes (Futuro)
  Future<List<Map<String, dynamic>>> fetchAllPendingVacations() async {
    try {
      final response = await _client
          .from(AppConstants.tableVacations)
          .select('*, users(full_name)') // Traz o nome do usuário junto (Join)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
}