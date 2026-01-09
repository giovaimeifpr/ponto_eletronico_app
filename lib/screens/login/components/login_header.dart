import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícone ou Logo da empresa
        const Icon(Icons.person_2_outlined, size: 80, color: AppColors.primary),
        const SizedBox(height: 20),
        const Text(
          'Ponto Eletrônico',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Faça login para continuar',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}