import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class MonthPickerField extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onMonthChanged;

  const MonthPickerField({
    super.key,
    required this.selectedDate,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Usando o padrão de cores do seu tema
        color: AppColors.primary.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primary),
            onPressed: () {
              // Calcula o mês anterior e envia para o widget pai
              onMonthChanged(DateTime(selectedDate.year, selectedDate.month - 1));
            },
          ),
          // InkWell para permitir clicar no texto e abrir um seletor (opcional no futuro)
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy', 'pt_BR').format(selectedDate).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.1,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.primary),
            onPressed: () {
              // Calcula o próximo mês e envia para o widget pai
              onMonthChanged(DateTime(selectedDate.year, selectedDate.month + 1));
            },
          ),
        ],
      ),
    );
  }
}