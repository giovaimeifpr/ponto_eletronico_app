import 'package:flutter/material.dart';
import 'components/login_header.dart';
import 'components/login_input_field.dart';
import 'components/login_button.dart';
import '../home/employ_selection_screen.dart';
import '../../services/login_services.dart';
import '../admin/home_admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      // 1. O serviço agora retorna o objeto completo do usuário (com a flag is_admin do banco)
      // Removi o parâmetro 'isAdmin' pois o sistema descobrirá isso após o login
      final user = await _loginService.getUserByEmailAndPassword(
        email,
        password,        
      );

      if (mounted) {
        // 2. Lógica de Redirecionamento (Bifurcação)

        if(user.onVacation == true) {
          // Se o usuário estiver de férias, mostra mensagem e não deixa entrar
          _showSnackBar("Usuário está de férias. Acesso negado.");
          return;
        } 
        if (user.isAdmin == true) {
          // Se for admin, vai para a tela de escolha (Portal)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeAdmin(user: user)),
          );
        } else {
          // Se for usuário comum, vai direto para o registro de ponto
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EmploySelectionScreen(user: user)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceAll("Exception:", ""));
      }
    } finally {
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
                  LoginButton(isLoading: _isLoading, onPressed: _handleLogin),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
