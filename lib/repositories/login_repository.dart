import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

class LoginRepository {
  final _client = Supabase.instance.client;

  // Busca dados brutos (Map)
  Future<Map<String, dynamic>> fetchRawUserData(String email) async {
    return await _client
        .from(AppConstants.tableUsers)
        .select()
        .eq('email', email)        
        .single();
  }

  // Verifica existência
  Future<Map<String, dynamic>?> checkUserExists(String email) async {
    return await _client
        .from(AppConstants.tableUsers)
        .select()
        .eq('email', email)
        .maybeSingle();
  }
  
  Future<Map<String, dynamic>?> checkSignIn(String email, String password) async { 
    return await _client
        .from(AppConstants.tableUsers)
        .select()
        .eq('email', email)
        .eq('password_hash', password)
        .maybeSingle(); 
  }
}
