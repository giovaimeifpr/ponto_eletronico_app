import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/user_model.dart';
import '../../../models/vacation_model.dart';
import '../../../services/vacations_service.dart';
import '../../home/components/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';

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
    final DateTime? start = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TEXTO PERSONALIZADO
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "SELECIONE A DATA DE INÍCIO DA ${index + 1}ª PARCELA E DE OK.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const Divider(height: 1),

              // DATE PICKER
              SizedBox(
                height: 450, // evita overflow
                child: child!,
              ),
            ],
          ),
        );
      },
    );

    if (start == null) return;

    final DateTime? end = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: start.add(const Duration(days: 5)),
      firstDate: start,
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "SELECIONE A DATA DE FIM DA ${index + 1}ª PARCELA E DE OK.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              SizedBox(height: 450, child: child!),
            ],
          ),
        );
      },
    );

    if (end != null) {
      setState(() {
        _selectedPeriods[index] = DateTimeRange(start: start, end: end);
      });
    }
  }

  // Future<void> _pickPeriod(int index) async {
  //   if (!_isEditing) return;

  //   // showDateRangePicker nativo configurado para PT-BR e mais leve
  //   final DateTimeRange? picked = await showDateRangePicker(
  //     context: context,
  //     locale: const Locale('pt', 'BR'), // Força Português
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime.now().add(const Duration(days: 730)),
  //     initialEntryMode:
  //         DatePickerEntryMode.calendarOnly, // Evita carregar lista infinita
  //     helpText: "SELECIONE O PERÍODO DA ${index + 1}ª PARCELA",
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: const ColorScheme.light(primary: AppColors.primary),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );

  //   if (picked != null) {
  //     setState(() => _selectedPeriods[index] = picked);
  //   }
  // }

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
            onTap: () => _pickPeriod(index),
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
                color: AppColors.primary.withOpacity(0.1),
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
