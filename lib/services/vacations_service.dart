import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/vacation_model.dart';
import '../repositories/vacation_repository.dart';


class VacationService {
  final VacationRepository _repository = VacationRepository();

  Future<List<VacationModel>> getUserVacations(String userId) async {
    try {
      final data = await _repository.fetchUserVacations(userId);
      return data.map((item) => VacationModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestVacation({
    required UserModel user,
    required List<DateTimeRange?> periods,
  }) async {
    try {
      // 1. Filtrar apenas períodos preenchidos
      final List<DateTimeRange> validPeriods = periods.whereType<DateTimeRange>().toList();

      if (validPeriods.isEmpty) throw "Selecione ao menos um período de férias.";

      // 2. Verificação de Sobreposição (Overlap)
      for (int i = 0; i < validPeriods.length; i++) {
        for (int j = i + 1; j < validPeriods.length; j++) {
          if (validPeriods[i].start.isBefore(validPeriods[j].end) &&
              validPeriods[j].start.isBefore(validPeriods[i].end)) {
            throw "Existe sobreposição entre os períodos selecionados.";
          }
        }
      }

      // 3. Validação de Regras CLT e Soma
      int totalDays = 0;
      bool hasMin14Days = false;

      for (var p in validPeriods) {
        int diff = p.end.difference(p.start).inDays + 1;
        if (diff < 5) throw "Nenhum período pode ser menor que 5 dias.";
        if (diff >= 14) hasMin14Days = true;
        totalDays += diff;
      }

      if (totalDays != 30) {
        throw "A soma total deve ser exatamente 30 dias. (Atual: $totalDays)";
      }

      if (!hasMin14Days) {
        throw "Pelo menos um dos períodos deve ter no mínimo 14 dias.";
      }

      // 4. Validação de 1 ano de casa (baseado no primeiro período)
      validPeriods.sort((a, b) => a.start.compareTo(b.start));
      if (user.hireDate != null) {
        final oneYear = DateTime(user.hireDate!.year + 1, user.hireDate!.month, user.hireDate!.day);
        if (validPeriods.first.start.isBefore(oneYear)) {
          throw "Você só tem direito a férias a partir de ${oneYear.day}/${oneYear.month}/${oneYear.year}";
        }
      }

      // 5. Preparar dados para o Repositório (Limpando as anteriores para o ano)
      // Nota: Em um sistema real, aqui você usaria uma Transaction para deletar as antigas e inserir as novas
      for (int i = 0; i < validPeriods.length; i++) {
        final data = {
          'user_id': user.id,
          'year_reference': DateTime.now().year,
          'period_index': i + 1,
          'start_date': validPeriods[i].start.toIso8601String().split('T')[0],
          'end_date': validPeriods[i].end.toIso8601String().split('T')[0],
          'total_days': validPeriods[i].end.difference(validPeriods[i].start).inDays + 1,
          'status': 'pending',
        };
        await _repository.requestVacation(data);
      }
    } catch (e) {
      rethrow;
    }
  }
}