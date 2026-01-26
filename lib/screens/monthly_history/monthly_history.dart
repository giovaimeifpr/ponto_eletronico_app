import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/punch_service.dart';
import '../home/components/history_table.dart';
import '../home/components/user_header.dart';
import '../../services/pdf_printer_service.dart';
import '../../core/theme/app_colors.dart';
import '../home/components/custom_app_bar.dart';
import 'components/month_picker_field.dart';

class MonthlyHistoryScreen extends StatefulWidget {
  final UserModel user;

  const MonthlyHistoryScreen({super.key, required this.user});

  @override
  State<MonthlyHistoryScreen> createState() => _MonthlyHistoryScreenState();
}

class _MonthlyHistoryScreenState extends State<MonthlyHistoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    // PADRONIZAÇÃO: Lógica para gerar a lista de dias do mês atual.
    // DateTime(ano, mes + 1, 0) retorna o último dia do mês atual.
    final int ultimoDia = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final List<DateTime> diasDoMes = List.generate(
      ultimoDia,
      (i) => DateTime(_selectedMonth.year, _selectedMonth.month, i + 1),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: "Histórico Mensal",
        extraActions: [
          // Botão de PDF padronizado para usar os dados carregados nesta tela
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
            onPressed: () => _pdfService.generateMonthlyReport(
              user: widget.user,
              punches: _punches,
              displayDays: diasDoMes,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header reutilizável com dados do usuário
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: UserHeader(user: widget.user, showAction: false),
          ),
          
          // Seletor de Mês 
          MonthPickerField(
            selectedDate: _selectedMonth,
            onMonthChanged: (newMonth) {
              setState(() {
                _selectedMonth = newMonth;
              });
              _fetchPunches();
            },
          ),
          
          
          // ÁREA DA TABELA: Expandida para ocupar o resto da tela
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: HistoryTable(
                      punches: _punches ,
                      workload: widget.user.workload,
                      displayDays: diasDoMes,
                      isMonthly: true, // Indica para a tabela usar lógica mensal
                      saldoAnterior: _saldoAnterior, // Repassa o saldo vindo do banco
                    ),
                  ),
          ),
        ],
      ),
    );
  }
 
}