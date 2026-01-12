// Este componente exibe o perfil do colaborador.

import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../monthly_history/monthly_history.dart';
import '../../../core/theme/app_colors.dart';

class UserHeader extends StatelessWidget {
  final UserModel user;
  final bool showAction;

  const UserHeader({super.key, required this.user, this.showAction = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Text(
                  user.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.jobTitle ?? 'Colaborador',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      "Carga Horária: ${user.workload}h semanais",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showAction) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthlyHistoryScreen(user: user),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month_outlined, size: 20),
                label: const Text("VISUALIZAR EXTRATO MENSAL"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
