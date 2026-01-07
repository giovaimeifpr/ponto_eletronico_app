Ponto Eletrônico App
Definição do Projeto Aplicativo mobile para registro de jornada de trabalho com validação de geolocalização (geofencing), garantindo que o colaborador registre o ponto apenas dentro do raio permitido pela empresa. O sistema utiliza integração em tempo real com banco de dados em nuvem para persistência segura dos horários.
Requisitos do sistema
https://docs.google.com/document/d/1LGSxnrtseBqnbW1sYLETNnbkQcVqNCrb20JLR55BlvI/edit?tab=t.0#heading=h.jacvqprxz4ws

Stack Tecnológica
Linguagem: Dart
Framework: Flutter (Mobile)
Backend as a Service: Supabase (PostgreSQL & Auth)
Ambiente de Desenvolvimento: Linux (Ubuntu 25.04)
Ferramentas: VS Code, Git, Android SDK & JDK 17

Diário de Bordo:

Nota do dia 06/01/2026
Setup Inicial: Configuração do projeto Flutter e integração inicial com o Supabase.
Modelagem de Dados: Criação da estrutura de usuários (UserModel) e mapeamento do JSON para objetos Dart.
Infraestrutura: Resolução de problemas de licenças do Android SDK e configuração do NDK para build mobile.

Nota do dia 07/01/2026
Configuração de Ambiente: Ajuste fino do compilador Java (JDK 17) e atualização do Gradle Wrapper para versão 8.13, garantindo compatibilidade com o Android SDK 36. Segurança e Variáveis de Ambiente: Implementação do arquivo .env para proteção de chaves de API e URL do Supabase.
Fluxo de Autenticação: Criação da LoginScreen com validação de e-mail via Supabase e navegação para a HomeScreen com passagem de parâmetros.
Correção de Navegação: Ajuste na lógica de Logout utilizando Navigator.pushReplacement para gestão correta da pilha de telas.