import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../home/components/history_table.dart';
import '../../../services/pdf_printer_service.dart';
import '../../../services/punch_service.dart';
import '../../home/components/custom_app_bar.dart';
import '../../home/components/user_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../monthly_history/components/month_picker_field.dart';

class TimesheetUserDetails extends StatefulWidget {
  final UserModel user;
  const TimesheetUserDetails({super.key, required this.user});

  @override
  State<TimesheetUserDetails> createState() => _TimesheetUserDetailsState();
}

class _TimesheetUserDetailsState extends State<TimesheetUserDetails> {
  DateTime _selectedMonth = DateTime.now();
  List<Map<String, dynamic>> _punches = [];
  bool _isLoading = false;
  double _saldoAnterior = 0.0;

  final PdfPrinterService _pdfService = PdfPrinterService();
  final PunchService _punchService = PunchService();

  @override
  void initState() {
    super.initState();
    _fetchPunches();
  }

  Future<void> _fetchPunches() async {
    setState(() => _isLoading = true);

    try {
      final DateTime mesAnterior = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
      final DateTime start = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        1,
        0,
        0,
        0,
      );
      final DateTime end = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      final results = await Future.wait([
        _punchService.getBalanceForMonth(widget.user.id, mesAnterior),
        _punchService.fetchCustomRange(widget.user.id, start, end),
      ]);

      setState(() {
       // Garantimos que o saldo é double (se vier null, fica 0.0)
        _saldoAnterior = (results[0]) as double;
        
        // A mágica: convertemos cada item da lista individualmente para Map<String, dynamic>
        // Isso remove o IdentityMap que causa o erro de tipo
        final List<dynamic> rawList = results[1] as List;
        _punches = rawList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      });
    } catch (e) {
      debugPrint("Erro ao buscar dados: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

 
  Future<void> _handleMonthClosing(double trabalhado, double meta) async {
    final double saldoAtual = trabalhado - meta;
    final double saldoFinal = _saldoAnterior + saldoAtual;

    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Fechamento"),
        content: Text(
          "O saldo final de ${saldoFinal.toStringAsFixed(1)}h será transportado para o próximo mês. Confirma?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _punchService.saveMonthlyBalance(
          userId: widget.user.id,
          month: _selectedMonth,
          balance: saldoFinal,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mês fechado com sucesso!"),
            backgroundColor: AppColors.success, // Usa o verde do seu tema
            behavior: SnackBarBehavior
                .floating, // Deixa o aviso "flutuando" acima do rodapé
          ),
        );
        _fetchPunches();
      } catch (e) {
        debugPrint("Erro ao fechar mês: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    final List<DateTime> diasDoMes = List.generate(
      daysInMonth,
      (i) => DateTime(_selectedMonth.year, _selectedMonth.month, i + 1),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: "Auditoria: ${widget.user.fullName.split(' ')[0]}",
        extraActions: [
          IconButton(
            onPressed: () => _pdfService.generateMonthlyReport(
              user: widget.user,
              punches: _punches,
              displayDays: diasDoMes,
            ),
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: UserHeader(user: widget.user, showAction: false),
          ),     

          // seletor de mês
          MonthPickerField(
            selectedDate: _selectedMonth,
            onMonthChanged: (newMonth) {
              setState(() {
                _selectedMonth = newMonth;
              });
              _fetchPunches();
            },
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: HistoryTable(
                      punches: _punches,
                      workload: widget.user.workload,
                      displayDays: diasDoMes,
                      isMonthly: true,
                      saldoAnterior: _saldoAnterior,
                      // PASSANDO OS PARÂMETROS QUE A TABELA CALCULA DE VOLTA PARA A FUNÇÃO
                      onClosingMonth: (trabalhado, meta) =>
                          _handleMonthClosing(trabalhado, meta),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
