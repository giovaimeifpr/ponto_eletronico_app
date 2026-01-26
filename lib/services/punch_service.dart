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
          orElse: () =>
              throw 'Erro: Registro de saída de intervalo não encontrado.',
        );

        final exitTime = DateTime.parse(exitPunchData['created_at']);
        final diff = DateTime.now().difference(exitTime).inMinutes;

        if (diff < 60) {
          // O throw aqui precisa ser capturado pela Home
          throw 'Intervalo insuficiente. Faltam ${60 - diff} minutos.';
        }
      }

      final position = await _locationService.getCurrentLocation();
      final distance = _locationService.calculateDistance(
        position.latitude,
        position.longitude,
      );

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
      DateTime segundaFeira = DateTime(
        inicioSemana.year,
        inicioSemana.month,
        inicioSemana.day,
        0,
        0,
        0,
      );

      // Pegamos o final do dia de hoje às 23:59:59
      DateTime fimDeHoje = DateTime(
        agora.year,
        agora.month,
        agora.day,
        23,
        59,
        59,
      );

      // .toIso8601String() garante o formato YYYY-MM-DDTHH:mm:ss.sss
      return await _repository.fetchPunchesByDateRange(
        userId,
        segundaFeira.toIso8601String(),
        fimDeHoje.toIso8601String(),
      );
    } catch (e) {
      throw AppErrors.handle(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchCustomRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await _repository.fetchPunchesByCustomRange(userId, start, end);
    } catch (e) {
      throw AppErrors.handle(e);
    }
  }

  Future<double> getBalanceForMonth(String userId, DateTime month) async {
    try {
      final data = await _repository.fetchBalanceForMonth(userId, month);

      if (data == null) return 0.0; // Se não houver fechamento, saldo é zero

      // Converte o valor do banco (double ou num) para double do Dart
      return (data['balance_hours'] as num).toDouble();
    } catch (e) {
      throw AppErrors.handle(e);
    }
  }

  // No seu Service
  Future<void> saveMonthlyBalance({
    required String userId,
    required DateTime month,
    required double balance,
  }) async {
    try {
      await _repository.upsertMonthlyBalance(
        userId: userId,
        month: month,
        balance: balance,
      );
    } catch (e) {
      throw AppErrors.handle(e);
    }
  }

  Future<Map<String, dynamic>> getFullMonthlyData(
    String userId,
    DateTime selectedMonth,
  ) async {
    try {
      final DateTime mesAnterior = DateTime(
        selectedMonth.year,
        selectedMonth.month - 1,
        1,
      );
      final DateTime start = DateTime(
        selectedMonth.year,
        selectedMonth.month,
        1,
        0,
        0,
        0,
      );
      final DateTime end = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      final results = await Future.wait([
        getBalanceForMonth(userId, mesAnterior),
        fetchCustomRange(userId, start, end),
      ]);

      // IGUAL AO TIMESHEETUSERDETAILS:
      final double saldoAnterior = results[0] as double;

      // AQUI ESTÁ O SEGREDO:
      // Primeiro garantimos que é uma List, depois forçamos o tipo do mapa interno.
      final List<dynamic> punchesRaw = results[1] as List;
      final List<Map<String, dynamic>> punches = punchesRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return {
        'saldoAnterior': saldoAnterior,
        'punches': punches,
        'diasDoMes': List.generate(
          end.day,
          (i) => DateTime(selectedMonth.year, selectedMonth.month, i + 1),
        ),
      };
    } catch (e) {
      // Se der erro aqui, o print vai nos dizer se é no cast ou na busca
      print("Erro interno no getFullMonthlyData: $e");
      throw AppErrors.handle(e);
    }
  }
}
