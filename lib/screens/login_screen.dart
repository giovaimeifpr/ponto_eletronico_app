import 'package:flutter/material.dart';
import '../services/login_services.dart';
import 'home.dart';
import '../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores e Serviços
  final _emailController = TextEditingController();
  final LoginService _loginService = LoginService();
  
  bool _isLoading = false;

  // Lógica de UI para processar o clique no botão
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      _showSnackBar('Por favor, digite seu e-mail');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Chama a camada de serviço
      final success = await _loginService.login(email);

      if (success && mounted) {
        // Navegação em caso de sucesso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userEmail: email),
          ),
        );
      } else {
        _showSnackBar('E-mail não cadastrado no sistema');
      }
    } catch (e) {
      // Captura erros tratados pelo Service (ex: sem internet)
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Função utilitária para mensagens rápidas (SnackBar)
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeader(),
            const SizedBox(height: 40),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  // --- Sub-widgets de UI ---

  Widget _buildHeader() {
    return const Column(
      children: [
        Icon(Icons.lock_person, size: 80, color: AppColors.primary),
        SizedBox(height: 20),
        Text(
          'Ponto Eletrônico',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'E-mail do Funcionário',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading 
          ? const SizedBox(
              height: 20, 
              width: 20, 
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background)
            ) 
          : const Text('Entrar'),
      ),
    );
  }
}