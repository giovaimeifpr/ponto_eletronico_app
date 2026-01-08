
# 🕒 Ponto Eletrônico App

### 📝 Definição do Projeto
Aplicativo mobile para registro de jornada de trabalho com validação de geolocalização (geofencing), garantindo que o colaborador registre o ponto apenas dentro do raio permitido pela empresa. O sistema utiliza integração em tempo real com banco de dados em nuvem para persistência segura dos horários.

### 📝 Requisitos do sistema:** [Link] 
(https://docs.google.com/document/d/1LGSxnrtseBqnbW1sYLETNnbkQcVqNCrb20JLR55BlvI/edit?tab=t.0#heading=h.jacvqprxz4ws)


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
* **Java JDK:** Versão 21 (configurado no `JAVA_HOME`).
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
*Desenvolvido como parte do curso de ADS - IFPR.*