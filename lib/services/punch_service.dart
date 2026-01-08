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
        final lastPunch = DateTime.parse(punchesToday.last['created_at']);
        final diff = DateTime.now().difference(lastPunch).inMinutes;
        if (diff < 60) {
          throw 'Intervalo insuficiente. Faltam ${60 - diff} minutos para completar 1h.';
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
  Future<List<Map<String, dynamic>>> fetchTodayHistory(String userId) async {
    try {
      return await _repository.getTodayPunches(userId);
    } catch (e) {
      throw AppErrors.handle(e);
    }
  }
}