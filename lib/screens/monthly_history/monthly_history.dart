import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../services/punch_service.dart';
import '../home/components/history_table.dart';
import '../home/components/user_header.dart';
import '../../services/pdf_printer_service.dart';

class MonthlyHistoryScreen extends StatefulWidget {
  final UserModel user;

  const MonthlyHistoryScreen({super.key, required this.user});

  @override
  State<MonthlyHistoryScreen> createState() => _MonthlyHistoryScreenState();
}

class _MonthlyHistoryScreenState extends State<MonthlyHistoryScreen> {
  final PunchService _punchService = PunchService();
  final PdfPrinterService _pdfService = PdfPrinterService();
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _monthlyPunches = [];
  bool _isLoading = false;
  

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() => _isLoading = true);
    try {
      // Calcula primeiro e último dia do mês selecionado
      final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      
      final data = await _punchService.fetchCustomRange(widget.user.id, start, end);
      setState(() => _monthlyPunches = data);
    } finally {
      setState(() => _isLoading = false);
    }
  }
 

  @override
  Widget build(BuildContext context) {
    final int diasNoMes = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final List<DateTime> diasDoMes = List.generate(
      diasNoMes, 
      (i) => DateTime(_selectedDate.year, _selectedDate.month, i + 1)
    );
    return Scaffold(
      
      appBar: AppBar(

            title: const Text("Histórico Mensal"), 
            actions: [
            IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _pdfService.generateMonthlyReport(
              user: widget.user,
              punches: _monthlyPunches,
              displayDays: diasDoMes, // Lista de DateTime que você já tem no build
            ),
          ),
        ],
      
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Center( // Garante que o conteúdo interno tente se centralizar
              child: UserHeader(user: widget.user, showAction: false),
            ),
          ),
          _buildMonthSelector(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: HistoryTable(
                    punches: _monthlyPunches, 
                    workload: widget.user.workload,
                    displayDays: diasDoMes,
                    isMonthly: true,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1));
              _loadMonthlyData();
            },
          ),
          Text(
            DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDate).toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1));
              _loadMonthlyData();
            },
          ),
        ],
      ),
    );
  }
}