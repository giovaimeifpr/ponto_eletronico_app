import 'package:flutter/material.dart';
import 'components/login_header.dart';
import 'components/login_input_field.dart';
import 'components/login_button.dart';
import '../home/home.dart';
import '../../services/login_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ... imports dos componentes acima ...

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // 1. Valida o formulário usando a GlobalKey (ADS: Garante que os campos não estão vazios)
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      // 2. Chama o serviço. Se falhar, ele pula direto para o 'catch'
      final user = await _loginService.getUserByEmailAndPassword(email, password);

      // 3. Se chegou aqui, o login foi um sucesso
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userEmail: user.email),
          ),
        );
      }
    } catch (e) {
      // 4. Captura o erro (E-mail inválido, senha errada ou sem internet)
      if (mounted) {
        _showSnackBar(e.toString());
      }
    } finally {
      // 5. Independente de sucesso ou erro, para o loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent, // Melhora o feedback visual de erro
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea evita que o conteúdo fique embaixo da barra de status (Xperia)
      body: SafeArea( 
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey, // Vincula a chave para validação
              child: Column(
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 40),
                  LoginInputField(
                    controller: _emailController,
                    label: 'E-mail',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  LoginInputField(
                    controller: _passwordController,
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),
                  LoginButton( 
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}