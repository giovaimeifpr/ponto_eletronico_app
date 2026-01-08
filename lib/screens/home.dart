import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import '../services/login_services.dart'; 
import '../services/punch_service.dart';
import '../core/theme/app_colors.dart'; 
import '../core/utils/time_formatter.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  const HomeScreen({super.key, required this.userEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LoginService _loginService = LoginService();
  final PunchService _punchService = PunchService();
  
  bool _isPunching = false;
  List<Map<String, dynamic>> _punchesToday = [];
  late Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loginService.getUserData(widget.userEmail);
  }

  Future<void> _loadHistory(String userId) async {
    try {
      final history = await _punchService.fetchTodayHistory(userId);
      if (mounted) {
        setState(() {
          _punchesToday = history;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar histórico: $e");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Sucesso!'),
          ],
        ),
        content: const Text('Seu ponto foi registrado e salvo no sistema.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTES DA TABELA (AGORA NO ESCOPO CORRETO DA CLASSE) ---

  Widget _buildHistoryTable() {
    String e1 = "--:--", s1 = "--:--", e2 = "--:--", s2 = "--:--";
    double totalHours = 0;

    // Mapeia os pontos da lista para as variáveis da tabela
    for (var punch in _punchesToday) {
      String time = TimeFormatter.formatTimestamp(punch['created_at']);
      switch (punch['entry_type']) {
        case 'entry_1': e1 = time; break;
        case 'exit_1': s1 = time; break;
        case 'entry_2': e2 = time; break;
        case 'exit_2': s2 = time; break;
      }
    }

    // Cálculo de horas totais do dia
    try {
      if (e1 != "--:--" && s1 != "--:--") {
        totalHours += TimeFormatter.calculateDuration(
          _punchesToday.firstWhere((p) => p['entry_type'] == 'entry_1')['created_at'],
          _punchesToday.firstWhere((p) => p['entry_type'] == 'exit_1')['created_at']
        );
      }
      if (e2 != "--:--" && s2 != "--:--") {
        totalHours += TimeFormatter.calculateDuration(
          _punchesToday.firstWhere((p) => p['entry_type'] == 'entry_2')['created_at'],
          _punchesToday.firstWhere((p) => p['entry_type'] == 'exit_2')['created_at']
        );
      }
    } catch (e) {
      debugPrint("Erro no cálculo de horas: $e");
    }

    return Column(
      children: [
        Text(
          "Mês de Referência: ${DateFormat('MMMM / yyyy', 'pt_BR').format(DateTime.now())}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 15,
            columns: const [
              DataColumn(label: Text('Dia')),
              DataColumn(label: Text('E1')),
              DataColumn(label: Text('S1')),
              DataColumn(label: Text('E2')),
              DataColumn(label: Text('S2')),
              DataColumn(label: Text('Total')),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text(DateFormat('dd/MM').format(DateTime.now()))),
                DataCell(Text(e1)),
                DataCell(Text(s1)),
                DataCell(Text(e2)),
                DataCell(Text(s2)),
                DataCell(Text("${totalHours.toStringAsFixed(1)}h")),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildWeeklySummary(totalHours),
      ],
    );
  }

  Widget _buildWeeklySummary(double todayHours) {
    double targetWeekly = 40.0;
    double balance = targetWeekly - todayHours;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Saldo Semanal (meta 40h):", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("${balance.toStringAsFixed(1)}h restantes", 
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _handlePunch(UserModel user) async {
    setState(() => _isPunching = true);
    try {
      await _punchService.registerPunch(user: user, punchesToday: _punchesToday);
      final updatedHistory = await _punchService.fetchTodayHistory(user.id);
      if (mounted) {
        setState(() {
          _punchesToday = updatedHistory;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isPunching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FutureBuilder<UserModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return _buildLoadingState();
          if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());
          if (!snapshot.hasData) return const Center(child: Text("Usuário não encontrado."));
          
          final user = snapshot.data!;
          if (_punchesToday.isEmpty) {
             _loadHistory(user.id);
          }
          return _buildSuccessState(user);
        },
      ),
    );
  }

  // --- UI HELPER METHODS ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Painel do Funcionário'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() => const Center(child: CircularProgressIndicator());
  Widget _buildErrorState(String error) => Center(child: Text('Erro: $error', style: const TextStyle(color: Colors.red)));

  Widget _buildSuccessState(UserModel user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildUserHeader(user),
            const Divider(height: 40),
            _buildHistoryTable(),
            const SizedBox(height: 40),
            _buildPunchClockButton(user),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(UserModel user) {
    return Column(
      children: [
        const Icon(Icons.account_circle, color: AppColors.primary, size: 100),
        const SizedBox(height: 15),
        Text(user.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(user.jobTitle ?? "Colaborador", style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPunchClockButton(UserModel user) {
    final String nextType = _punchService.getNextPunchType(_punchesToday);
    String label = "REGISTRAR ENTRADA";
    bool isCompleted = false;

    switch (nextType) {
      case 'exit_1': label = "SAÍDA INTERVALO"; break;
      case 'entry_2': label = "VOLTA INTERVALO"; break;
      case 'exit_2': label = "REGISTRAR SAÍDA"; break;
      case 'completed': label = "PONTO DO DIA FINALIZADO"; isCompleted = true; break;
    }

    return SizedBox(
      width: 280, height: 70,
      child: ElevatedButton.icon(
        onPressed: (isCompleted || _isPunching) ? null : () => _handlePunch(user),
        icon: _isPunching 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Icon(isCompleted ? Icons.check_circle : Icons.timer),
        label: Text(_isPunching ? 'PROCESSANDO...' : label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? Colors.grey : AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}