class AppErrors {
  static String handle(Object error) {
    final errorString = error.toString();

    if (errorString.contains('SocketException')) {
      return 'Sem conexão com a internet. Verifique seu sinal.';
    }
    if (errorString.contains('single')) {
      return 'Registro não encontrado em nossa base de dados.';
    }
    if (errorString.contains('401') || errorString.contains('Invalid login')) {
      return 'Credenciais inválidas. Verifique seu e-mail.';
    }
    
    return 'Ocorreu um erro inesperado: $errorString';
  }
}