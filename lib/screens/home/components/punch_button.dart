// O PunchButton funciona como uma máquina de estados visual que consulta o histórico do banco
// para determinar dinamicamente o próximo passo da jornada, alterando rótulos, ícones e cores 
// automaticamente. Ele gerencia a interatividade de forma inteligente, desabilitando o clique 
// e exibindo um indicador de carregamento durante o processamento do GPS para evitar registros 
// duplicados. Ao atingir o limite de quatro marcações diárias, o componente assume um estado 
// finalizado e inativo, garantindo a integridade do fluxo de trabalho e impedindo lançamentos 
// indevidos após o encerramento do expediente.


import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/punch_service.dart';

class PunchButton extends StatelessWidget {
  final bool isPunching;
  final List<Map<String, dynamic>> punches;
  final VoidCallback onPressed; // Função que será executada na Home

  const PunchButton({
    super.key,
    required this.isPunching,
    required this.punches,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Instanciamos o service apenas para usar o método auxiliar de tipos
    final punchService = PunchService();
    final String nextType = punchService.getNextPunchType(punches);
    
    String label = "REGISTRAR ENTRADA";
    bool isCompleted = false;

    // Máquina de estados visual
    switch (nextType) {
      case 'exit_1': label = "SAÍDA INTERVALO"; break;
      case 'entry_2': label = "VOLTA INTERVALO"; break;
      case 'exit_2': label = "REGISTRAR SAÍDA"; break;
      case 'completed': 
        label = "PONTO DO DIA FINALIZADO"; 
        isCompleted = true; 
        break;
    }

    return SizedBox(
      width: 280, 
      height: 70,
      child: ElevatedButton.icon(
        // Se estiver completo ou processando, o botão fica desativado (null)
        onPressed: (isCompleted || isPunching) ? null : onPressed,
        icon: isPunching 
            ? const SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : Icon(isCompleted ? Icons.check_circle : Icons.timer),
        label: Text(
          isPunching ? 'PROCESSANDO...' : label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? Colors.grey : AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}