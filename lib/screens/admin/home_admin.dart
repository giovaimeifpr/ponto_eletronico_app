import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../screens/home/home.dart';
import 'admin_dashboard.dart'; // Vamos criar este em seguida
import '../home/components/custom_app_bar.dart';
import '../home/components/user_header.dart';

class HomeAdmin extends StatelessWidget {
  final UserModel user;

  const HomeAdmin({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Portal de Acesso"),
      body: SingleChildScrollView(
        // 1. Adicionado para permitir rolagem
        child: Container(
          // 2. Garante que o conteúdo ocupe ao menos a altura da tela para centralizar
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centraliza verticalmente se houver espaço
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 10),

                  // 3. UserHeader costuma ser largo. Envolvê-lo em um Card ou limitar o tamanho ajuda na estética
                  UserHeader(user: user, showAction: false),

                  const SizedBox(height: 20),
                  const Text(
                    "Selecione como deseja prosseguir:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 30),

                  _buildMenuButton(
                    context,
                    title: "PAINEL ADMINISTRADOR",
                    subtitle: "Gestão de equipe, relatórios e ajustes",
                    icon: Icons.dashboard_customize,
                    color: Colors.blue.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboard(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildMenuButton(
                    context,
                    title: "REGISTRAR MEU PONTO",
                    subtitle: "Acessar tela de registro diário",
                    icon: Icons.timer_outlined,
                    color: Colors.green.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(userEmail: user.email),
                        ),
                      );
                    },
                  ),
                  // Um pequeno respiro no final para não colar na borda ao rolar
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
