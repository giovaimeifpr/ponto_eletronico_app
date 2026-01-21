import 'package:flutter/material.dart';

class VacationPickerDialog {
  static Future<DateTimeRange?> show(
    BuildContext context, {
    required int index,
    required List<DateTimeRange?> selectedPeriods,
  }) async {
    // Helpers internos
    bool hasOverlap(DateTimeRange a, DateTimeRange b) {
      return a.start.isBefore(b.end) && b.start.isBefore(a.end);
    }

    // Preparação de dados fora do loop do diálogo
    final List<DateTimeRange> otherPeriods = [];
    int daysUsedInOthers = 0;
    for (int i = 0; i < selectedPeriods.length; i++) {
      if (i != index && selectedPeriods[i] != null) {
        otherPeriods.add(selectedPeriods[i]!);
        daysUsedInOthers += selectedPeriods[i]!.end.difference(selectedPeriods[i]!.start).inDays + 1;
      }
    }

    DateTime? start;
    DateTime? end;

    return showDialog<DateTimeRange>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            // 1. Cálculos Reativos
            int currentTotalDays = 0;
            if (start != null && end != null) {
              currentTotalDays = end!.difference(start!).inDays + 1;
            }

            final int totalDaysAfterSelection = daysUsedInOthers + currentTotalDays;
            final int remainingAfterSelection = 30 - totalDaysAfterSelection;

            // 2. Validações
            bool hasOverlapWithOthers = false;
            if (start != null && end != null) {
              final currentRange = DateTimeRange(start: start!, end: end!);
              hasOverlapWithOthers = otherPeriods.any((p) => hasOverlap(currentRange, p));
            }

            bool validMinDays = currentTotalDays >= 5;
            bool isValidFlow = remainingAfterSelection == 0 || remainingAfterSelection >= 5;
            bool notExceed30 = totalDaysAfterSelection <= 30;
            
            bool alreadyHas14 = otherPeriods.any((p) => (p.end.difference(p.start).inDays + 1) >= 14);
            bool requirement14Met = totalDaysAfterSelection == 30 
                ? (alreadyHas14 || currentTotalDays >= 14) 
                : true;

            bool canConfirm = start != null && end != null && validMinDays && 
                             isValidFlow && notExceed30 && !hasOverlapWithOthers;

            return AlertDialog(
              title: Text("Período da ${index + 1}ª Parcela", textAlign: TextAlign.center),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CalendarDatePicker(
                      initialDate: start ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                      onDateChanged: (date) {
                        setLocalState(() {
                          if (start == null || end != null) {
                            start = date;
                            end = null;
                          } else {
                            if (date.isBefore(start!)) {
                              end = start; start = date;
                            } else {
                              end = date;
                            }
                          }
                        });
                      },
                    ),
                    const Divider(),
                    _buildValidationMessage(
                      currentTotalDays: currentTotalDays,
                      remainingAfterSelection: remainingAfterSelection,
                      hasOverlap: hasOverlapWithOthers,
                      isValidFlow: isValidFlow,
                      notExceed30: notExceed30,
                      requirement14Met: requirement14Met,
                      isClosed: totalDaysAfterSelection == 30,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                TextButton(
                  onPressed: canConfirm 
                      ? () => Navigator.pop(context, DateTimeRange(start: start!, end: end!)) 
                      : null,
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildValidationMessage({
    required int currentTotalDays,
    required int remainingAfterSelection,
    required bool hasOverlap,
    required bool isValidFlow,
    required bool notExceed30,
    required bool requirement14Met,
    required bool isClosed,
  }) {
    if (currentTotalDays == 0) return const Text("Selecione o início e fim", style: TextStyle(fontSize: 12));

    List<Widget> warnings = [];
    TextStyle errStyle = const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500);

    if (currentTotalDays < 5) {
      warnings.add(Text("Mínimo de 5 dias obrigatório.", style: errStyle));
    } else if (!notExceed30) {
      warnings.add(Text("Ultrapassou o limite de 30 dias.", style: errStyle));
    } else if (hasOverlap) {
      warnings.add(Text("Conflito com outro período.", style: errStyle));
    } else if (!isValidFlow) {
      warnings.add(Text("Inválido: restariam $remainingAfterSelection dias (mín. 5).", style: errStyle));
    } else if (isClosed && !requirement14Met) {
      warnings.add(Text("CLT: Uma das parcelas deve ter ≥ 14 dias.", style: errStyle));
    } else {
      warnings.add(Text("Selecionado: $currentTotalDays dias", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)));
      if (isClosed) warnings.add(const Text("Saldo de 30 dias completo!", style: TextStyle(color: Colors.green, fontSize: 12)));
    }

    return Column(children: warnings);
  }
}