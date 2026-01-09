
// Este componente lida com a moldura superior e a navegação de saída.

import 'package:flutter/material.dart';
import '../../login/login_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Painel do Funcionário'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair do Aplicativo',
          onPressed: () {
            // Lógica de logout centralizada aqui
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ],
    );
  }

  // Define a altura padrão da AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}