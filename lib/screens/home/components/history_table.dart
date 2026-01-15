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
                  if (isDomingo) return AppColors.error.withValues(alpha: 0.05);
                  if (isSabado)
                    return AppColors.warning.withValues(alpha: 0.05);
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
        _buildWeeklySummary(periodTotal),
      ],
    );
  }

  Widget _buildWeeklySummary(double totalTrabalhado) {
    // Cálculo da meta e saldos
    double metaReferencia;

    if (isMonthly) {
      // 1. Descobrimos quantos dias de semana (Seg-Sex) existem no mês exibido
      // displayDays é a lista que você já passa para o componente
      int diasUteis = displayDays
          .where(
            (date) =>
                date.weekday != DateTime.saturday &&
                date.weekday != DateTime.sunday,
          )
          .length;
      double jornadaSemanal = workload / 5; // Jornada diária baseada na semanal          
      metaReferencia = jornadaSemanal * diasUteis;
    } else {
      metaReferencia = workload.toDouble();
    }

    
    double saldoDoMes = totalTrabalhado - metaReferencia;
    double saldoSubsequente = saldoAnterior + saldoDoMes;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // LINHA 1: TOTAL TRABALHADO / META
          _buildFooterRow(
            isMonthly ? "Trabalhado no Mês:" : "Trabalhado na Semana:",
            "${totalTrabalhado.toStringAsFixed(1)}h / ${metaReferencia.toStringAsFixed(1)}h",
            Colors.black,
          ),
          const Divider(),

          // LINHA 2: SALDO DO MÊS ANTERIOR
          _buildFooterRow(
            "Saldo Anterior a compensar:",
            "${saldoAnterior >= 0 ? '+' : ''}${saldoAnterior.toStringAsFixed(1)}h",
            saldoAnterior >= 0 ? AppColors.success : AppColors.error,
          ),

          // LINHA 3: SALDO DO MÊS ATUAL
          _buildFooterRow(
            "Saldo deste Mês:",
            "${saldoDoMes >= 0 ? '+' : ''}${saldoDoMes.toStringAsFixed(1)}h",
            saldoDoMes >= 0 ? AppColors.success : AppColors.error,
          ),

          const SizedBox(height: 12),

          // LINHA 4: CONTAINER DE DESTAQUE (SALDO SUBSEQUENTE)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: saldoSubsequente >= 0
                  ? AppColors.success.withValues(alpha: 0.05)
                  : AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildFooterRow(
              "Saldo para Mês Subsequente:",
              "${saldoSubsequente >= 0 ? '+' : ''}${saldoSubsequente.toStringAsFixed(1)}h",
              saldoSubsequente >= 0 ? AppColors.success : AppColors.error,
              isBold: true,
            ),
          ), // O Container termina aqui!
          // LINHA 5: BOTÃO DE FECHAMENTO (FICA DENTRO DA COLUMN, FORA DO CONTAINER ACIMA)
          if (isMonthly && onClosingMonth != null) ...[
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () => onClosingMonth!(totalTrabalhado, metaReferencia),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.lock_outline, size: 18),
              label: const Text("FECHAR MÊS E SALVAR SALDO"),
            ),
          ],
        ],
      ),
    );
  }

  // Função auxiliar para criar as linhas dentro do rodapé
  Widget _buildFooterRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
