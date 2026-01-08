import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart'; // Importe sua tela de login
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 1. Garante a inicialização dos bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // carregar os dados de tradução do português do Brasil:
  await initializeDateFormatting('pt_BR', null);

  // 2. Carrega as variáveis do .env
  await dotenv.load(fileName: ".env");

  // 3. Inicializa o Supabase usando as chaves do .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ponto Eletrônico',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(), // Começa pela tela de login
    );
  }
}