// Este componente atua como o motor de processamento visual da HomeScreen, sendo responsável
// por filtrar a lista bruta de registros do Supabase e transformá-la em colunas organizadas de horários.
// Ele encapsula toda a complexidade dos cálculos de horas trabalhadas e saldo semanal, garantindo que a
// lógica matemática não polua a camada de interface principal. Além disso, utiliza a internacionalização
// para exibir o mês de referência e as datas em português, oferecendo um feedback claro e profissional
// sobre a jornada de trabalho do colaborador.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/time_formatter.dart';
import 'history_table_functions.dart';


class HistoryTable extends StatelessWidget {
  final List<Map<String, dynamic>> punches;
  final int workload;
  final List<DateTime> displayDays;
  final bool isMonthly;
  final double saldoAnterior;
  final Function(double trabalhado, double meta)? onClosingMonth;

  const HistoryTable({
    super.key,
    required this.punches,
    required this.workload,
    required this.displayDays,
    this.isMonthly = false,
    this.saldoAnterior = 0.0,
    this.onClosingMonth,
  });

  @override
  Widget build(BuildContext context) {
    double periodTotal = 0; // Renomeado de weekly para period (mais genérico)

    return Column(
      children: [
        // Título dinâmico: mostra do primeiro ao último dia da lista recebida
        Text(
          "Período: ${DateFormat('dd/MM').format(displayDays.first)} a ${DateFormat('dd/MM').format(displayDays.last)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 12,
            horizontalMargin: 10,
            columns: const [
              DataColumn(label: Text('Semana')),
              DataColumn(label: Text('Dia')),
              DataColumn(label: Text('E1')),
              DataColumn(label: Text('S1')),
              DataColumn(label: Text('E2')),
              DataColumn(label: Text('S2')),
              DataColumn(label: Text('Total')),
            ],
            // 1. Usamos o displayDays que o componente recebeu via construtor
            rows: displayDays.map((dia) {
              // Filtrar os pontos deste dia específico
              var pontosDoDia = punches.where((p) {
                DateTime dataPonto = DateTime.parse(p['created_at']);
                // Comparamos dia, mês e ANO para não misturar dados de anos diferentes
                return dataPonto.day == dia.day &&
                    dataPonto.month == dia.month &&
                    dataPonto.year == dia.year;
              }).toList();

              String e1 = "--:--", s1 = "--:--", e2 = "--:--", s2 = "--:--";
              double horasDoDia = 0;

              for (var p in pontosDoDia) {
                String time = TimeFormatter.formatTimestamp(p['created_at']);
                switch (p['entry_type']) {
                  case 'entry_1':
                    e1 = time;
                    break;
                  case 'exit_1':
                    s1 = time;
                    break;
                  case 'entry_2':
                    e2 = time;
                    break;
                  case 'exit_2':
                    s2 = time;
                    break;
                }
              }

              // Cálculo de horas
              try {
                if (e1 != "--:--" && s1 != "--:--") {
                  horasDoDia += TimeFormatter.calculateDuration(
                    pontosDoDia.firstWhere(
                      (p) => p['entry_type'] == 'entry_1',
                    )['created_at'],
                    pontosDoDia.firstWhere(
                      (p) => p['entry_type'] == 'exit_1',
                    )['created_at'],
                  );
                }
                if (e2 != "--:--" && s2 != "--:--") {
                  horasDoDia += TimeFormatter.calculateDuration(
                    pontosDoDia.firstWhere(
                      (p) => p['entry_type'] == 'entry_2',
                    )['created_at'],
                    pontosDoDia.firstWhere(
                      (p) => p['entry_type'] == 'exit_2',
                    )['created_at'],
                  );
                }
              } catch (_) {}

              periodTotal += horasDoDia;

              // Lógica de Cores Condicionais
              bool isSabado = dia.weekday == DateTime.saturday;
              bool isDomingo = dia.weekday == DateTime.sunday;

              // Estilo para Texto (Normal ou Vermelho)
              TextStyle getStyle({bool isAfternoon = false}) {
                Color textColor = AppColors.textPrimary;
                if (isDomingo) {
                  textColor = AppColors.error;
                } else if (isSabado) {
                  textColor = AppColors.warning;
                }
                return TextStyle(fontSize: 12, color: textColor);
              }

              return DataRow(
                // Opcional: Colorir o fundo da linha inteira se for final de semana
                color: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (isDomingo) {
                    return AppColors.error.withValues(alpha: 0.05);
                  }
                  if (isSabado){
                    return AppColors.warning.withValues(alpha: 0.05);
                  }
                  return null;
                }),
                cells: [
                  // Coluna 1: Dia da semana por extenso (curto)
                  DataCell(
                    Text(
                      DateFormat(
                        'E',
                        'pt_BR',
                      ).format(dia).toUpperCase().replaceAll('.', ''),
                      style: getStyle(),
                    ),
                  ),
                  // Coluna 2: Data
                  DataCell(
                    Text(DateFormat('dd/MM').format(dia), style: getStyle()),
                  ),
                  // Colunas de Horários
                  DataCell(Text(e1, style: getStyle())),
                  DataCell(Text(s1, style: getStyle())),
                  DataCell(Text(e2, style: getStyle(isAfternoon: true))),
                  DataCell(Text(s2, style: getStyle(isAfternoon: true))),
                  // Coluna Total
                  DataCell(
                    Text(
                      "${horasDoDia.toStringAsFixed(1)}h",
                      style: getStyle().copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        HistoryTableFunctions(
          punches: punches,
          isMonthly: isMonthly,
          saldoAnterior: saldoAnterior,
          workload: workload,
          displayDays: displayDays,
          onClosingMonth: onClosingMonth,
        ).buildWeeklySummary(periodTotal),
      ],
    );
  }
}
