import 'package:flutter/material.dart';

class VacationPickerDialog {
  // Criamos um método estático que pode ser chamado de qualquer lugar
  static Future<void> show({
    required BuildContext context,
    required int index,
    required List<DateTimeRange?> selectedPeriods,
    required Function(DateTimeRange) onSelected, // Callback para atualizar a tela pai
  }) async {
    int daysInOtherPeriods = 0;
    List<DateTimeRange> otherRanges = [];

    for (int i = 0; i < selectedPeriods.length; i++) {
      if (i != index && selectedPeriods[i] != null) {
        daysInOtherPeriods +=
            selectedPeriods[i]!.end.difference(selectedPeriods[i]!.start).inDays + 1;
        otherRanges.add(selectedPeriods[i]!);
      }
    }

    DateTime? start;
    DateTime? end;

    // O showDialog deve ser retornado ou aguardado
    await showDialog<DateTimeRange>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            int currentTotal = 0;
            if (start != null && end != null) {
              currentTotal = end!.difference(start!).inDays + 1;
            }

            int grandTotal = daysInOtherPeriods + currentTotal;
            int remaining = 30 - grandTotal;

            bool min5Days = currentTotal >= 5;
            bool notExceed30 = grandTotal <= 30;
            bool isOverlap = false;
            if (start != null && end != null) {
              final current = DateTimeRange(start: start!, end: end!);
              isOverlap = otherRanges.any(
                (o) => current.start.isBefore(o.end) && o.start.isBefore(current.end),
              );
            }

            bool validFlow = remaining == 0 || remaining >= 5;
            bool alreadyHas14 = otherRanges.any(
              (r) => (r.end.difference(r.start).inDays + 1) >= 14,
            );
            
            bool requirement14Met = true;
            if (grandTotal == 30) {
              requirement14Met = alreadyHas14 || currentTotal >= 14;
            }

            bool lastPeriodMustComplete30 = true;
            if (index == 2 && currentTotal > 0) {
              lastPeriodMustComplete30 = grandTotal == 30;
            }

            bool canConfirm = start != null &&
                end != null &&
                min5Days &&
                notExceed30 &&
                !isOverlap &&
                validFlow &&
                requirement14Met &&
                lastPeriodMustComplete30;

            return AlertDialog(
              title: Text("Parcela ${index + 1}"),
              content: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: CalendarDatePicker(
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
                                end = start;
                                start = date;
                              } else {
                                end = date;
                              }
                            }
                          });
                        },
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (currentTotal > 0) ...[
                      Text(
                        currentTotal < 5
                            ? "Dias selecionados: $currentTotal, mínimo é 5 dias."
                            : "Dias selecionados: $currentTotal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (currentTotal < 5 || !notExceed30)
                              ? Colors.red
                              : Colors.blue,
                        ),
                      ),
                      if (isOverlap)
                        const Text("⚠️ Conflito de datas!",
                            style: TextStyle(color: Colors.red, fontSize: 12)),
                      if (!validFlow && grandTotal < 30)
                        Text("⚠️ Erro: Restariam $remaining dias (mín. 5).",
                            style: const TextStyle(color: Colors.red, fontSize: 12)),
                      if (index == 2 && grandTotal != 30)
                        Text("⚠️ Deve completar 30 dias (Faltam: ${30 - (daysInOtherPeriods + currentTotal)}).",
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center),
                      if (grandTotal == 30 && !requirement14Met)
                        const Text("⚠️ CLT: Pelo menos uma parcela deve ter 14 dias.",
                            style: TextStyle(color: Colors.red, fontSize: 12)),
                    ] else
                      const Text("Selecione o início e o fim no calendário",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: canConfirm
                      ? () => Navigator.pop(dialogContext, DateTimeRange(start: start!, end: end!))
                      : null,
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        onSelected(result); // Envia o resultado de volta para a tela pai
      }
    });
  }
}