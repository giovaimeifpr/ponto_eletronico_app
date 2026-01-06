import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/user_model.dart'; // Certifique-se de que o caminho está correto

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = 'https://ympsuhothfzknpjlsczh.supabase.co';
  const supabaseKey = 'sb_publishable_8m2q4kmmeLVrEllJmqMbEA_sz0vX2Mh';
 
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Função que busca os dados (Lógica que você testou no Node, agora em Dart)
  Future<UserModel> fetchUserData() async {
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('email', 'teste@empresa.com') // O usuário que inserimos antes
        .single();
    
    return UserModel.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Teste de Conexão Supabase')),
        body: FutureBuilder<UserModel>(
          future: fetchUserData(),
          builder: (context, snapshot) {
            // Enquanto carrega...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Se der erro (ex: internet ou banco)...
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            // Se der certo!
            final user = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  Text('Conectado como: ${user.fullName}', 
                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Cargo: ${user.jobTitle ?? "Não informado"}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}