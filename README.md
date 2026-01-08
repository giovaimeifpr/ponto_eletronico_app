
# 🕒 Ponto Eletrônico App

### 📝 Definição do Projeto
Aplicativo mobile para registro de jornada de trabalho com validação de geolocalização (geofencing), garantindo que o colaborador registre o ponto apenas dentro do raio permitido pela empresa. O sistema utiliza integração em tempo real com banco de dados em nuvem para persistência segura dos horários.

### 📝 Requisitos do sistema: *([Link](https://docs.google.com/document/d/1LGSxnrtseBqnbW1sYLETNnbkQcVqNCrb20JLR55BlvI/edit?tab=t.0#heading=h.jacvqprxz4ws))*.


---

### 🛠️ Stack Tecnológica
* **Linguagem:** [Dart](https://dart.dev/)
* **Framework:** [Flutter](https://flutter.dev/) (Mobile)
* **Backend as a Service:** [Supabase](https://supabase.com/) (PostgreSQL & Auth)
* **Ambiente de Desenvolvimento:** Linux (Ubuntu 25.04)
* **Ferramentas:** VS Code, Git, Android SDK & JDK 21


--- 

### 🚀 Como Rodar o Projeto

#### 1. Pré-requisitos de Ambiente
Certifique-se de ter o ambiente configurado para desenvolvimento Android:
* **Flutter SDK:** Versão stable.
* **Java JDK:** Versão 17 (configurado no `JAVA_HOME`).
* **Android SDK:** Command-line tools e Build-tools 36.1.0+.
* **Gradle:** Versão 8.13 ou superior.

#### 2. Configuração do Backend (Supabase)
Este projeto utiliza o Supabase como banco de dados PostgreSQL.
1. Crie um projeto no [Supabase](https://supabase.com/).
2. Execute o script SQL para criação das tabelas e permissões:
   * [🔗 Script SQL de Estrutura do Banco](#) *([Link](https://docs.google.com/document/d/1hjfHnGMAlfmK3sShLwq-If5s9wafDnUZp_2UnPDdQ34/edit?tab=t.0))*.

#### 3. Variáveis de Ambiente
Na raiz do projeto, crie um arquivo chamado `.env` e adicione suas chaves (não compartilhe este arquivo):
```env
SUPABASE_URL=[https://sua-url-aqui.supabase.co](https://sua-url-aqui.supabase.co)
SUPABASE_KEY=sua-chave-anon-aqui
```
---

### 📅 Diário de Bordo

#### **Nota: 06/01/2026**
* **Setup Inicial:** Configuração do projeto Flutter e integração inicial com o Supabase.
* **Modelagem de Dados:** Criação da estrutura de usuários (`UserModel`) e mapeamento do JSON para objetos Dart.
* **Infraestrutura:** Resolução de problemas de licenças do Android SDK e configuração do NDK para build mobile.

#### **Nota: 07/01/2026**
* **Configuração de Ambiente:** Ajuste fino do compilador Java (JDK 21) e atualização do Gradle Wrapper para versão 8.13, garantindo compatibilidade com o Android SDK 36.
* **Segurança:** Implementação do arquivo `.env` para proteção de chaves de API e URL do Supabase.
* **Fluxo de Autenticação:** Criação da `LoginScreen` com validação de e-mail via Supabase e navegação para a `HomeScreen` com passagem de parâmetros.
* **Correção de Navegação:** Ajuste na lógica de Logout utilizando `Navigator.pushReplacement` para gestão correta da pilha de telas.

---
#### **Nota: 08/01/2026**
🚀 Atualizações do Dia (Sessão de Desenvolvimento)
🏗️ Reestruturação da Arquitetura (Clean Architecture)
Camada de Services: Implementação do AuthService, PunchService e LocationService, centralizando as regras de negócio e isolando a lógica de hardware (GPS) e banco de dados.

Camada de Repositories: Refatoração do LoginRepository e PunchRepository para garantir que a comunicação com o Supabase siga o padrão de responsabilidade única.

Core & Errors: Centralização do tratamento de exceções com o AppErrors, permitindo mensagens amigáveis ao usuário para erros complexos de rede ou banco.

📍 Registro de Ponto Inteligente (RN01 e RN02)
Geofencing (Cerca Virtual): Integração com o GPS do dispositivo para capturar latitude e longitude no momento do registro.

Validação de Raio: Implementação de trava de segurança que impede o registro caso o funcionário esteja a mais de 200 metros da sede da empresa.

Máquina de Estados do Botão: O botão da Home tornou-se dinâmico, identificando automaticamente o próximo passo do dia:

Registrar Entrada
Saída Intervalo
Volta Intervalo (Com validação obrigatória de 1 hora mínima de descanso).
Registrar Saída
Ponto Finalizado (Botão desabilitado após o ciclo completo).

📊 Interface e Feedback Visual (UI/UX)
Tabela de Histórico Diário: Implementação de uma DataTable que exibe em tempo real os horários registrados (E1, S1, E2, S2).

Cálculo de Horas e Saldo: Lógica para cálculo automático de horas trabalhadas no dia e exibição do saldo semanal restante para a meta de 40 horas.

Gestão de Estados (StatefulWidget): Refatoração da HomeScreen para gerenciar estados de carregamento (loading) e feedback de sucesso via Dialogs e SnackBars.

🛠️ Melhorias Técnicas
Gerenciamento de Dependências: Adição dos pacotes geolocator (localização) e intl (formatação de datas e internacionalização para PT-BR).

Segurança de Dados: Implementação de Row Level Security (RLS) no Supabase para proteção dos registros de ponto.

Ciclo de Vida: Uso estratégico de initState e Future.wait para carregamento encadeado de dados do usuário e histórico.

---

*Desenvolvido como parte do curso de ADS - IFPR.*