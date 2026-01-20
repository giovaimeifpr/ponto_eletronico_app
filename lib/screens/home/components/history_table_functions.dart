import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';


class HistoryTableFunctions extends StatelessWidget {
  final List<Map<String, dynamic>> punches;
  final int workload;
  final List<DateTime> displayDays;
  final bool isMonthly;
  final double saldoAnterior;
  final Function(double trabalhado, double meta)? onClosingMonth;
  
  
  const HistoryTableFunctions({
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
    return buildWeeklySummary(0.0);
  }

 Widget buildWeeklySummary(double totalTrabalhado) {
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