import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

class UserRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final response = await _client
          .from(AppConstants.tableUsers)
          .select()
          .order('full_name', ascending: true); // Organiza de A-Z

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
}