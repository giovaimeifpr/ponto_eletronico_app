import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HistoryTableFunctions extends StatelessWidget {
  final List<Map<String, dynamic>> punches;
  final int workload;
  final List<DateTime> displayDays;
  final bool isMonthly;
  final double? saldoAnterior; // Transformado em opcional para segurança
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
    // Nota: O valor aqui deve ser passado pela HistoryTable. 
    // Se a intenção é usar o componente de forma isolada, 
    // garantimos que o valor inicial não quebre o layout.
    return buildWeeklySummary(0.0);
  }

  Widget buildWeeklySummary(double totalTrabalhado) {
    // 1. BLINDAGEM CONTRA NULOS (Prevenção do erro JSNoSuchMethodError)
    // Garantimos que nenhuma variável usada em cálculos ou formatação seja null
    final double safeTotalTrabalhado = totalTrabalhado; 
    final double safeSaldoAnterior = saldoAnterior ?? 0.0;
    
    // 2. CÁLCULO DA META
    double metaReferencia;

    if (isMonthly) {
      // Descobrimos quantos dias de semana (Seg-Sex) existem no mês exibido
      int diasUteis = displayDays
          .where(
            (date) =>
                date.weekday != DateTime.saturday &&
                date.weekday != DateTime.sunday,
          )
          .length;
      
      // Jornada diária baseada na semanal (ex: 44h / 5 = 8.8h)
      double jornadaDiaria = workload / 5;           
      metaReferencia = jornadaDiaria * diasUteis;
    } else {
      metaReferencia = workload.toDouble();
    }

    // 3. CÁLCULOS DE SALDO
    double saldoDoMes = safeTotalTrabalhado - metaReferencia;
    double saldoSubsequente = safeSaldoAnterior + saldoDoMes;

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
            "${safeTotalTrabalhado.toStringAsFixed(1)}h / ${metaReferencia.toStringAsFixed(1)}h",
            Colors.black,
          ),
          const Divider(),

          // LINHA 2: SALDO DO MÊS ANTERIOR (Seguro contra Null)
          _buildFooterRow(
            "Saldo Anterior a compensar:",
            "${safeSaldoAnterior >= 0 ? '+' : ''}${safeSaldoAnterior.toStringAsFixed(1)}h",
            safeSaldoAnterior >= 0 ? AppColors.success : AppColors.error,
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
          ),

          // LINHA 5: BOTÃO DE FECHAMENTO
          if (isMonthly && onClosingMonth != null) ...[
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () => onClosingMonth!(safeTotalTrabalhado, metaReferencia),
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