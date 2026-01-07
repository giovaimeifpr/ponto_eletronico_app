import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Função que busca os dados do usuário logado
  Future<UserModel> fetchUserData() async {
    // Aqui buscamos o usuário atual. 
    // Dica: Futuramente pegaremos o e-mail dinamicamente do login
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('email', 'teste@empresa.com') 
        .single();
    
    return UserModel.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Funcionário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
          // Navega de volta para o Login e remove a Home da memória
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
          )
        ],
      ),
      body: FutureBuilder<UserModel>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final user = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, color: Colors.blue, size: 80),
                const SizedBox(height: 10),
                Text(
                  'Bem-vindo, ${user.fullName}', 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                ),
                Text('Cargo: ${user.jobTitle ?? "Não informado"}', 
                     style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 40),
                
                // Botão que usaremos para a RN02 (GPS) depois
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica de bater ponto virá aqui
                  },
                  icon: const Icon(Icons.timer),
                  label: const Text('Registrar Ponto'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}