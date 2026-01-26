import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/login_services.dart';
import '../../../services/punch_service.dart';
import '../../../core/theme/app_colors.dart';
import '../components/history_table.dart';
import '../components/user_header.dart';
import '../components/punch_button.dart';
import '../components/custom_app_bar.dart';

class Timesheet extends StatefulWidget {
  final String userEmail;
  const Timesheet({super.key, required this.userEmail});

  @override
  State<Timesheet> createState() => _TimesheetState();
}

class _TimesheetState extends State<Timesheet> {
  final LoginService _loginService = LoginService();
  final PunchService _punchService = PunchService();
  bool _isPunching = false;
  List<Map<String, dynamic>> _weeklyPunches = [];
  late Future<UserModel> _userFuture;
  double _saldoAnterior = 0.0;

  @override
  void initState() {
    super.initState();
    // Inicializa a busca do usuário uma única vez
    _userFuture = _loginService.getUserData(widget.userEmail);
    _userFuture.then((user) {
      // Após obter o usuário, carrega o histórico semanal
      _loadHistory(user.id);
    });
  }

  // --- LÓGICA DE NEGÓCIO ---
  Future<void> _loadHistory(String userId) async {
    setState(() => _isPunching = true);

    try {
      final DateTime agora = DateTime.now();

      final DateTime segunda = DateTime(
        agora.year,
        agora.month,
        agora.day,
      ).subtract(Duration(days: agora.weekday - 1));

      final DateTime domingo = DateTime(
        segunda.year,
        segunda.month,
        segunda.day + 6,
        23,
        59,
        59,
      );

      final DateTime mesAnterior = DateTime(agora.year, agora.month - 1, 1);

      final results = await Future.wait([
        _punchService.getBalanceForMonth(userId, mesAnterior),
        _punchService.fetchCustomRange(userId, segunda, domingo),
      ]);

      final List<dynamic> rawList = results[1] as List;

      if (mounted) {
        setState(() {
          _saldoAnterior = results[0] as double;
          _weeklyPunches = rawList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar histórico semanal: $e");
    } finally {
      if (mounted) setState(() => _isPunching = false);
    }
  }

  Future<void> _handlePunch(
    UserModel user,
    List<Map<String, dynamic>> hojePunches,
  ) async {
    setState(() => _isPunching = true);
    try {
      // Tenta registrar o ponto
      await _punchService.registerPunch(user: user, punchesToday: hojePunches);

      // Se deu certo, busca o histórico semanal atualizado
      final updatedHistory = await _punchService.fetchWeeklyHistory(user.id);

      if (mounted) {
        setState(() {
          _weeklyPunches = updatedHistory;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      // TRATAMENTO DE ERRO / AVISO
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(e.toString()),
                ), // Exibe a mensagem do throw
              ],
            ),
            backgroundColor: Colors.orange.shade800, // Cor de alerta
            behavior: SnackBarBehavior
                .floating, // Deixa a snackbar "flutuando" acima do botão
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPunching = false);
    }
  }

  // --- FEEDBACK VISUAL ---

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
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

  // --- CONSTRUÇÃO DA TELA (UI) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Ponto Eletrônico"),
      body: FutureBuilder<UserModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Usuário não encontrado."));
          }

          final user = snapshot.data!;
         
          return _buildSuccessState(user);
        },
      ),
    );
  }

  Widget _buildSuccessState(UserModel user) {
    // ADS: Filtramos a lista semanal para obter apenas os registros de HOJE
    final DateTime agora = DateTime.now();
    final DateTime segunda = agora.subtract(Duration(days: agora.weekday - 1));
    final List<DateTime> semanaAtual = List.generate(
      7,
      (i) => segunda.add(Duration(days: i)),
    );
    final List<Map<String, dynamic>> hojePunches = _weeklyPunches.where((p) {
      final dataPonto = DateTime.parse(p['created_at']);
      return dataPonto.day == agora.day &&
          dataPonto.month == agora.month &&
          dataPonto.year == agora.year;
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            UserHeader(user: user),
            const Divider(height: 40),
            HistoryTable(
              punches: _weeklyPunches,
              workload: user.workload,
              displayDays: semanaAtual,
              saldoAnterior: _saldoAnterior,
            ), // A tabela continua vendo a semana toda
            const SizedBox(height: 40),
            PunchButton(
              isPunching: _isPunching,
              punches: hojePunches, // O BOTÃO agora vê apenas HOJE
              onPressed: () => _handlePunch(
                user,
                hojePunches,
              ), // Passamos o filtro para a função
            ),
          ],
        ),
      ),
    );
  }
}
