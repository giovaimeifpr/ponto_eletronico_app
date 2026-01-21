import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/user_model.dart';
import '../../../models/vacation_model.dart';
import '../../../services/vacations_service.dart';
import '../../home/components/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import 'components/vacation_picker_dialog.dart';

class Vacations extends StatefulWidget {
  final UserModel user;
  const Vacations({super.key, required this.user});

  @override
  State<Vacations> createState() => _VacationsState();
}

class _VacationsState extends State<Vacations> {
  final VacationService _vacationService = VacationService();
  final List<DateTimeRange?> _selectedPeriods = [null, null, null];
  VacationStatus _statusGeral = VacationStatus.pending;
  String? _motivoRejeicao;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final list = await _vacationService.getUserVacations(widget.user.id);
      if (list.isNotEmpty) {
        setState(() {
          _statusGeral = list.first.status;
          _motivoRejeicao = list.first.rejectionReason;
          for (var v in list) {
            if (v.periodIndex <= 3) {
              _selectedPeriods[v.periodIndex - 1] = DateTimeRange(
                start: v.startDate,
                end: v.endDate,
              );
            }
          }
          _isEditing = false;
        });
      } else {
        setState(() => _isEditing = true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPeriod(int index) async {
    if (!_isEditing) return;

    // 1. Preparação: Pega o que já foi usado nas OUTRAS parcelas
    int daysInOtherPeriods = 0;
    List<DateTimeRange> otherRanges = [];

    for (int i = 0; i < _selectedPeriods.length; i++) {
      if (i != index && _selectedPeriods[i] != null) {
        daysInOtherPeriods +=
            _selectedPeriods[i]!.end
                .difference(_selectedPeriods[i]!.start)
                .inDays +
            1;
        otherRanges.add(_selectedPeriods[i]!);
      }
    }

    DateTime? start;
    DateTime? end;

    await showDialog<DateTimeRange>(
      context: context,
      builder: (context) {
        // O StatefulBuilder é o que permite as mensagens mudarem enquanto o usuário clica
        return StatefulBuilder(
          builder: (context, setLocalState) {
            // --- CÁLCULOS REATIVOS (Rodam a cada clique) ---
            int currentTotal = 0;
            if (start != null && end != null) {
              currentTotal = end!.difference(start!).inDays + 1;
            }

            int grandTotal = daysInOtherPeriods + currentTotal;
            int remaining = 30 - grandTotal;

            // Validações
            bool min5Days = currentTotal >= 5;
            bool notExceed30 = grandTotal <= 30;
            bool isOverlap = false;
            if (start != null && end != null) {
              final current = DateTimeRange(start: start!, end: end!);
              isOverlap = otherRanges.any(
                (o) =>
                    current.start.isBefore(o.end) &&
                    o.start.isBefore(current.end),
              );
            }

            // Regra da Parcela Intermediária: não pode deixar 1 a 4 dias sobrando
            bool validFlow = remaining == 0 || remaining >= 5;

            // Regra Final: Se estiver tentando fechar os 30, tem que ter tido uma de 14
            bool alreadyHas14 = otherRanges.any(
              (r) => (r.end.difference(r.start).inDays + 1) >= 14,
            );
            bool requirement14Met = true;
            if (grandTotal == 30) {
              requirement14Met = alreadyHas14 || currentTotal >= 14;
            }

            // REGRA DA TERCEIRA PARCELA: Se for a última (index 2), DEVE completar 30
            bool lastPeriodMustComplete30 = true;
            if (index == 2 && currentTotal > 0) {
              lastPeriodMustComplete30 = grandTotal == 30;
            }

            // Botão OK Habilitado
            bool canConfirm =
                start != null &&
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
                width: 350, // Largura fixa para evitar erro de hit test
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

                    // --- ÁREA DE AVISOS (EXIBIÇÃO EM TEMPO REAL) ---
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
                        const Text(
                          "⚠️ Conflito de datas!",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      if (!validFlow && grandTotal < 30)
                        Text(
                          "⚠️ Erro: Restariam $remaining dias para usar em um período (mín. 5).",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      if (index == 2 && grandTotal != 30)
                        Text(
                          "⚠️ A última parcela deve completar 30 dias (Faltam: ${30 - (daysInOtherPeriods + currentTotal)}).",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (grandTotal == 30 && !requirement14Met)
                        const Text(
                          "⚠️ CLT: Pelo menos uma parcela deve ter 14 dias.",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                    ] else
                      const Text(
                        "Selecione o início e o fim no calendário",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: canConfirm
                      ? () => Navigator.pop(
                          context,
                          DateTimeRange(start: start!, end: end!),
                        )
                      : null,
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result != null) setState(() => _selectedPeriods[index] = result);
    });
  }

  Future<void> _handleSave() async {
    try {
      setState(() => _isLoading = true);
      await _vacationService.requestVacation(
        user: widget.user,
        periods: _selectedPeriods,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Planejamento enviado!"),
          backgroundColor: AppColors.success,
        ),
      );
      _loadInitialData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = _selectedPeriods.whereType<DateTimeRange>().fold(
      0,
      (sum, p) => sum + p.end.difference(p.start).inDays + 1,
    );

    return Scaffold(
      appBar: const CustomAppBar(title: "Planejamento de Férias"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeaderInfo(total),
                  const SizedBox(height: 20),
                  ...List.generate(3, (i) => _buildPeriodField(i)),
                  const SizedBox(height: 20),
                  _buildStatusSection(),
                  if (_isEditing) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "SALVAR PLANEJAMENTO",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodField(int index) {
    final range = _selectedPeriods[index];
    final int diasNoPeriodo = range != null
        ? range.end.difference(range.start).inDays + 1
        : 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: _isEditing ? AppColors.primary : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            onTap: () => _isEditing ? _pickPeriod(index) : null,
            leading: CircleAvatar(
              backgroundColor: range != null
                  ? AppColors.primary
                  : Colors.grey.shade200,
              child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              range == null ? "Selecionar Período" : "Período Definido",
            ),
            subtitle: Text(
              range == null
                  ? "Toque para abrir o calendário"
                  : "${DateFormat('dd/MM/yyyy', 'pt_BR').format(range.start)} - ${DateFormat('dd/MM/yyyy', 'pt_BR').format(range.end)}",
            ),
            trailing: const Icon(Icons.calendar_month_outlined),
          ),
          if (range != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Text(
                "Total desta parcela: $diasNoPeriodo dias",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    Color statusColor = _statusGeral == VacationStatus.approved
        ? Colors.green
        : _statusGeral == VacationStatus.rejected
        ? Colors.red
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            _statusGeral == VacationStatus.approved
                ? Icons.verified
                : Icons.hourglass_top,
            color: statusColor,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            "STATUS: ${_statusGeral.name.toUpperCase()}",
            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
          ),
          if (_statusGeral == VacationStatus.rejected &&
              _motivoRejeicao != null) ...[
            const Divider(),
            Text(
              "Motivo: $_motivoRejeicao",
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          if (!_isEditing)
            OutlinedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              label: const Text("EDITAR PLANEJAMENTO"),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(int total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: total == 30 ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            total == 30 ? Icons.check_circle : Icons.info,
            color: total == 30 ? Colors.green : Colors.blue,
          ),
          const SizedBox(width: 10),
          Text(
            "Total selecionado: $total / 30 dias",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: total == 30 ? Colors.green.shade900 : Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
