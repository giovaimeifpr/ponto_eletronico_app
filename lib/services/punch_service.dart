import '../repositories/punch_repository.dart';
import 'location_service.dart';
import '../core/errors/app_errors.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class PunchService {
  final PunchRepository _repository = PunchRepository();
  final LocationService _locationService = LocationService();

  // Determina qual o próximo tipo de ponto baseado na lista de hoje
  String getNextPunchType(List<Map<String, dynamic>> punches) {
    if (punches.isEmpty) return 'entry_1';
    if (punches.length == 1) return 'exit_1';
    if (punches.length == 2) return 'entry_2';
    if (punches.length == 3) return 'exit_2';
    return 'completed';
  }

  Future<void> registerPunch({
    required UserModel user,
    required List<Map<String, dynamic>> punchesToday,
  }) async {
    try {
      final String nextType = getNextPunchType(punchesToday);
      if (nextType == 'completed') throw 'Ponto do dia já finalizado.';

      // VALIDAÇÃO DA 1 HORA (Para entry_2)
      if (nextType == 'entry_2') {
          // Buscamos especificamente o registro de saída do almoço na lista de hoje
          final exitPunchData = punchesToday.firstWhere(
            (p) => p['entry_type'] == 'exit_1',
            orElse: () => throw 'Erro: Registro de saída de intervalo não encontrado.'
          );
          
          final exitTime = DateTime.parse(exitPunchData['created_at']);
          final diff = DateTime.now().difference(exitTime).inMinutes;
          
          if (diff < 60) {
            // O throw aqui precisa ser capturado pela Home
            throw 'Intervalo insuficiente. Faltam ${60 - diff} minutos.';
          }
      }

      final position = await _locationService.getCurrentLocation();
      final distance = _locationService.calculateDistance(position.latitude, position.longitude);

      if (distance > AppConstants.allowedRadiusInMeters) {
        throw 'Fora do raio permitido ($distance metros).';
      }

      await _repository.insertPunch(
        userId: user.id,
        lat: position.latitude,
        lon: position.longitude,
        type: nextType,
        distance: distance,
      );
    } catch (e) {
      throw AppErrors.handle(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchWeeklyHistory(String userId) async {
    try {
      DateTime agora = DateTime.now();
      
      // Pegamos a segunda-feira desta semana às 00:00:00
      DateTime inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));
      DateTime segundaFeira = DateTime(inicioSemana.year, inicioSemana.month, inicioSemana.day, 0, 0, 0);

      // Pegamos o final do dia de hoje às 23:59:59
      DateTime fimDeHoje = DateTime(agora.year, agora.month, agora.day, 23, 59, 59);

      // .toIso8601String() garante o formato YYYY-MM-DDTHH:mm:ss.sss
      return await _repository.fetchPunchesByDateRange(
        userId, 
        segundaFeira.toIso8601String(),
        fimDeHoje.toIso8601String()
      );
    } catch (e) {
      throw AppErrors.handle(e);
    }
  }
}