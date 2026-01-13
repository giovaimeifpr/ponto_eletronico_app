// Este componente lida com a moldura superior e a navegação de saída.

import 'package:flutter/material.dart';
import '../../../screens/login/login_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? extraActions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: [
        // Se passarmos botões extras (como o de PDF), eles aparecem antes do Logout
        if (extraActions != null) ...extraActions!,
        
        // Botão de Logout fixo e padronizado
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair do Aplicativo',
          onPressed: () {
            // Dica: Aqui você também poderia limpar o cache/token do Supabase
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, // Remove todas as telas anteriores da memória
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}