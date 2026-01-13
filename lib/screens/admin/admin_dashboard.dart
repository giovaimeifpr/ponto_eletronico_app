import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/components/custom_app_bar.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Painel Administrativo"),
      body: Column(
        children: [
          // Banner de teste para confirmar a navegação
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColors.secondary.withValues(alpha: 0.05),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.warning),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "Módulo Administrativo Carregado com Sucesso!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: AppColors.warning
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Expanded(
            child: Center(
              child: Text(
                "Área do RH em construção...\nEm breve: Lista de Colaboradores",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondary, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}