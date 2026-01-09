// Este componente exibe o perfil do colaborador.

import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../core/theme/app_colors.dart';

class UserHeader extends StatelessWidget {
  final UserModel user;

  const UserHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícone de Perfil com cor do tema
        const Icon(
          Icons.account_circle, 
          color: AppColors.primary, 
          size: 100
        ),
        const SizedBox(height: 15),
        
        // Nome Completo
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold
          ),
        ),
        
        const SizedBox(height: 5),
        
        // Cargo/Função
        Text(
          user.jobTitle ?? "Colaborador",
          style: const TextStyle(
            fontSize: 16, 
            color: AppColors.secondary
          ),
        ),
      ],
    );
  }
}