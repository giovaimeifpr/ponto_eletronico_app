// Este componente atua como o motor de processamento visual da HomeScreen, sendo responsável 
// por filtrar a lista bruta de registros do Supabase e transformá-la em colunas organizadas de horários. 
// Ele encapsula toda a complexidade dos cálculos de horas trabalhadas e saldo semanal, garantindo que a 
// lógica matemática não polua a camada de interface principal. Além disso, utiliza a internacionalização 
// para exibir o mês de referência e as datas em português, oferecendo um feedback claro e profissional
// sobre a jornada de trabalho do colaborador.


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/time_formatter.dart';

class HistoryTable extends StatelessWidget {
  final List<Map<String, dynamic>> punches;

  const HistoryTable({super.key, required this.punches});

  @override
  Widget build(BuildContext context) {
    double weeklyTotal = 0;

    // 1. Gerar lista com os dias da semana atual (Segunda a Sexta)
    DateTime agora = DateTime.now();
    DateTime segunda = agora.subtract(Duration(days: agora.weekday - 1));
    List<DateTime> diasDaSemana = List.generate(5, (index) => segunda.add(Duration(days: index)));

    return Column(
      children: [
        Text(
          "Semana de Referência: ${DateFormat('dd/MM').format(segunda)} a ${DateFormat('dd/MM').format(diasDaSemana.last)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 12,
            columns: const [
              DataColumn(label: Text('Dia')),
              DataColumn(label: Text('E1')),
              DataColumn(label: Text('S1')),
              DataColumn(label: Text('E2')),
              DataColumn(label: Text('S2')),
              DataColumn(label: Text('Total')),
            ],
            // 2. Mapear cada dia da semana para uma linha da tabela
            rows: diasDaSemana.map((dia) {
              // Filtrar os pontos deste dia específico
              var pontosDoDia = punches.where((p) {
                DateTime dataPonto = DateTime.parse(p['created_at']);
                return dataPonto.day == dia.day && dataPonto.month == dia.month;
              }).toList();

              String e1 = "--:--", s1 = "--:--", e2 = "--:--", s2 = "--:--";
              double horasDoDia = 0;

              // Preencher horários
              for (var p in pontosDoDia) {
                String time = TimeFormatter.formatTimestamp(p['created_at']);
                switch (p['entry_type']) {
                  case 'entry_1': e1 = time; break;
                  case 'exit_1': s1 = time; break;
                  case 'entry_2': e2 = time; break;
                  case 'exit_2': s2 = time; break;
                }
              }

              // Calcular total do dia para somar no semanal
              try {
                if (e1 != "--:--" && s1 != "--:--") {
                  horasDoDia += TimeFormatter.calculateDuration(
                    pontosDoDia.firstWhere((p) => p['entry_type'] == 'entry_1')['created_at'],
                    pontosDoDia.firstWhere((p) => p['entry_type'] == 'exit_1')['created_at']
                  );
                }
                if (e2 != "--:--" && s2 != "--:--") {
                  horasDoDia += TimeFormatter.calculateDuration(
                    pontosDoDia.firstWhere((p) => p['entry_type'] == 'entry_2')['created_at'],
                    pontosDoDia.firstWhere((p) => p['entry_type'] == 'exit_2')['created_at']
                  );
                }
              } catch (_) {}
              
              weeklyTotal += horasDoDia;

              return DataRow(cells: [
                DataCell(Text(DateFormat('dd/MM').format(dia), style: const TextStyle(fontSize: 12))),
                DataCell(Text(e1, style: const TextStyle(fontSize: 12))),
                DataCell(Text(s1, style: const TextStyle(fontSize: 12))),
                DataCell(Text(e2, style: const TextStyle(fontSize: 12))),
                DataCell(Text(s2, style: const TextStyle(fontSize: 12))),
                DataCell(Text("${horasDoDia.toStringAsFixed(1)}h", style: const TextStyle(fontWeight: FontWeight.bold))),
              ]);
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        _buildWeeklySummary(weeklyTotal),
      ],
    );
  }

  Widget _buildWeeklySummary(double totalTrabalhado) {
    double metaSemanal = 40.0;
    double saldo = totalTrabalhado - metaSemanal;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total na Semana:", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            "${totalTrabalhado.toStringAsFixed(1)}h / 40h", 
            style: TextStyle(
              color: saldo >= 0 ? Colors.green : Colors.blue, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}