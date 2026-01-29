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
#### **Nota: 09/01/2026**

1. Refatoração e Arquitetura (Clean Code)

Modularização da Home: A tela principal (HomeScreen) foi dividida em componentes independentes para melhorar a manutenção e escalabilidade.

HomeAppBar: Gerencia o título e a ação de Logout.
UserHeader: Exibe informações de perfil do UserModel (foto, nome e cargo).
HistoryTable: Processa e exibe o histórico semanal de marcações.
PunchButton: Controla a lógica visual e os estados do registro de ponto.

Refatoração do Login: Implementação de componentes para campos de entrada (LoginInputField) e botão de submissão (LoginSubmitButton), preparando a tela para futuros métodos de autenticação (como Google ou Biometria).

2. Implementações Funcionais (Ponto Eletrônico)

Histórico Semanal: A consulta ao banco de dados foi expandida de "diária" para "semanal" (fetchWeeklyHistory), permitindo que a tabela exiba os registros de segunda a sexta-feira.

Máquina de Estados no Botão: O PunchButton agora identifica dinamicamente o próximo tipo de marcação (Entrada 1, Saída 1, Entrada 2 ou Saída 2) com base nos registros já existentes.

Geofencing: Implementação da validação de localização, bloqueando o registro caso o colaborador esteja fora do raio de distância permitido em relação à empresa.

3. Regras de Negócio e Validações (RN)

Intervalo Interjornada: Implementação da trava de segurança que impede o registro da "Volta do Intervalo" (entry_2) caso não tenha transcorrido o tempo mínimo de 60 minutos desde a saída.

Limite de Marcações: O sistema foi configurado para permitir o máximo de 4 marcações diárias, desativando o botão e exibindo o status de "Ponto Finalizado" após a conclusão.

Sincronização de Horário: A validação da hora do registro passou a ser feita diretamente com o servidor para evitar fraudes por alteração manual no relógio do dispositivo.

4. Correções e Ajustes Técnicos

Filtro de Dados: Ajuste na lógica para que o botão de registro consulte apenas os pontos do dia atual, evitando conflitos com o histórico de dias anteriores da mesma semana.

Tratamento de Erros: Padronização do AppErrors.handle para exibir mensagens amigáveis ao usuário via SnackBar em caso de falha de GPS ou intervalo insuficiente.

---

#### **Nota: 12/01/2026**

Progresso do dia:

Extrato Mensal e PDF:

Criação da tela de Histórico Mensal com navegação entre meses.
Implementação do gerador de PDF (Espelho de Ponto) usando os pacotes pdf e printing.
Adição de campos de assinatura para o funcionário e para o RH no rodapé do relatório.
Refatoração de Componentes (Clean Code):
Parametrização da HistoryTable: agora o mesmo componente exibe tanto a semana (7 dias) quanto o mês (28 a 31 dias).
Evolução do UserHeader: inclusão de uma trava (flag) para esconder o botão de extrato quando o usuário já está na tela de histórico.
Lógica de cores para finais de semana mantida e adaptada para a visualização mensal.
Infraestrutura e Banco de Dados:
Sincronização de Fuso Horário: Configuração do banco de dados Supabase para o timezone "America/Sao_Paulo" via comando SQL.
Alinhamento total entre o horário registrado no servidor e o horário local de Brasília, eliminando erros de conversão no PDF.

Regras de Negócio:

Adição do campo "Workload" (carga horária semanal) no banco de dados e no modelo de usuário.
Cálculo de meta mensal dinâmica baseada na carga horária individual de cada colaborador.

---

#### **Nota: 13/01/2026**

Progresso do dia:

1. Arquitetura de Perfis (Admin vs. Colaborador):
Implementação da flag is_admin no modelo de usuário e sincronização com o banco de dados Supabase.
Criação de uma lógica de redirecionamento inteligente no Login: o sistema agora identifica o perfil e encaminha o usuário para o fluxo correspondente.
Desenvolvimento da tela HomeAdmin (Portal de Acesso), que permite ao gestor escolher entre gerenciar a equipe ou registrar seu próprio ponto.

2. Refatoração e Componentização (Clean Code):
Criação da CustomAppBar reutilizável: centralização da lógica de Logout e suporte a ações dinâmicas (como o botão de PDF), eliminando a repetição de código em múltiplas telas.
Ajuste de responsividade: implementação de SingleChildScrollView com BoxConstraints para evitar erros de transbordamento (Overflow) em diferentes tamanhos de tela.
Padronização do componente UserHeader para exibição de perfil tanto na área do funcionário quanto no portal do administrador.

3. Correções Técnicas e Backend:

Padronização do mapeamento JSON no UserModel para garantir compatibilidade com as colunas do PostgreSQL (Snake Case vs. Camel Case).
Correção definitiva do fuso horário nos relatórios: aplicação do método .toLocal() no serviço de geração de PDF para alinhar os registros do banco com o Horário de Brasília.
Implementação de queries SQL para limpeza e população de dados em massa para testes de estresse no relatório mensal.

4. Interface e UX:

Adição de botões de ação intuitivos no Portal do Admin com suporte a títulos, subtítulos e ícones dinâmicos.
Melhoria na segurança da navegação com o uso de pushAndRemoveUntil no logout, garantindo que a sessão seja encerrada corretamente na pilha de telas do Flutter.

---

#### **Nota: 15/01/2026**

Novas Funcionalidades: Módulo Administrativo & Auditoria
1. Painel de Gestão de Colaboradores:

Implementação de listagem dinâmica de funcionários consumindo dados do Supabase.

Criação de fluxo de navegação hierárquica: Dashboard -> Perfil do Usuário -> Histórico de Ponto.

Integração da CustomAppBar em todas as novas telas administrativas para manter a identidade visual e o botão de logout centralizado.

2. Auditoria Temporal Dinâmica:

Implementação de seletor de mês e ano (showDatePicker) para consulta de períodos retroativos.

Refatoração da busca no banco de dados para suportar intervalos customizados (fetchCustomRange), permitindo ao Admin visualizar qualquer mês (ex: Dezembro/2025) com carregamento instantâneo.

3. Inteligência de Banco de Horas (Regra de Negócio):

Cálculo de Dias Úteis: Migração da meta mensal de "semanas médias (4.33)" para "jornada diária real", baseada nos dias úteis do mês (Segunda a Sexta), eliminando erros de arredondamento.

Saldo Transmissível: Criação do conceito de "Saldo para Mês Subsequente", onde o saldo anterior (positivo ou negativo) é somado ao desempenho do mês atual.

Rodapé de Fechamento: Novo componente visual no histórico que exibe:

Total Trabalhado vs. Meta do Período.

Saldo do Mês Anterior (A compensar).

Saldo do Mês Atual.

Saldo Final para transporte.

4. Persistência e Fechamento de Mês:

Tabela monthly_balances: Criação da estrutura no banco para salvar o "carimbo" do saldo final de cada funcionário.

Operação de Upsert: Implementação de lógica que salva ou atualiza o fechamento, garantindo que o Admin possa re-auditar meses se necessário sem duplicar dados.

Confirmação de Auditoria: Diálogo de confirmação antes de gravar o saldo final no banco de dados.

🛠️ Ajustes Técnicos:
Correção de bugs de escopo (funções Future dentro do build).

Padronização de Null Safety para campos opcionais como job_title.

Otimização de performance com Future.wait para buscar pontos e saldos anteriores em paralelo.

---
#### **Nota: 20/01/2026**

🚀 Novas Funcionalidades e Arquitetura
1. Reestruturação do Fluxo de Acesso (Login & Portais):

Login Inteligente: Implementação de lógica de redirecionamento pós-autenticação. O sistema agora identifica o perfil do usuário e apresenta o portal adequado.

Portal de Acesso Admin: Nova interface para administradores com botões de acesso rápido ao "Painel do Gestor" e ao "Registro de Ponto" pessoal, unificando a experiência.

Portal do Colaborador (Modularizado): Criação de uma tela de seleção de módulos para o usuário comum, separando claramente as funcionalidades de Ponto, Férias e Ocorrências.

2. Módulo de Gestão de Férias (RF05):

Modelagem de Banco de Dados: Criação da tabela vacations no Supabase com suporte a parcelamento em até 3 períodos (period_index).

Planejamento Anual Único: Interface redesenhada para que o colaborador planeje seus 30 dias de uma só vez, oferecendo uma visão sistêmica do descanso anual.

Status e Feedback: Integração de campos de status (pending, approved, rejected) com exibição visual de motivos de rejeição diretamente no card da parcela.

3. Motor de Regras de Negócio (CLT & Compliance):

Validação de Direito: Implementação de trava de segurança que verifica a hire_date (data de admissão) e só permite solicitações após o primeiro ano de empresa.

Matemática de Precisão: - Soma obrigatória de exatamente 30 dias.

Regra de no mínimo um período de 14 dias.

Trava para parcelas menores que 5 dias.

Detecção de Sobreposição (Overlap): Algoritmo que impede o usuário de selecionar datas conflitantes entre os três períodos do planejamento.

4. UI/UX e Localização:

Internacionalização (i18n): Configuração global do app para pt-BR, traduzindo calendários, dias da semana e seletores nativos.

Performance de Calendário: Ajuste no showDateRangePicker para o modo calendarOnly, reduzindo o consumo de memória ao carregar meses futuros.

Feedback em Tempo Real: Contador dinâmico de dias por parcela e somatório total acumulado com cores de alerta (Azul para planejamento em curso / Verde para 30 dias fechados).

🛠️ Especificações Técnicas Adicionadas
Banco de Dados: Inclusão da coluna hire_date na tabela users e novas políticas de segurança para a tabela vacations.

Service Layer: VacationService consolidado como o cérebro das regras de negócio, protegendo o repositório de dados inválidos.

Componentes: Uso de DateTimeRange, ExpansionTile para detalhes de rejeição e LinearProgressIndicator para controle de saldo de dias.

---

#### **Nota: 21/01/2026**

1. Restruturação no módulo de férias para respeitar as regras de negócios.
Foi criado um componente vacation_picker para lidar só com essas regras.

---

#### **Nota: 23/01/2026**

1. Correção de erros de salvamento, edição no módulo férias. Foi finalizado as correções.

---
#### **Nota: 26/01/2026**

1. RESOLUÇÃO DO ERRO DE TIPAGEM (IdentityMap):
- Identificamos que o driver do Supabase retorna um 'IdentityMap', que causava falha ao tentar converter diretamente para List<Map<String, dynamic>>.
- Solução: Implementamos uma limpeza de dados no Service e Repository utilizando o padrão:
  (response as List).map((item) => Map<String, dynamic>.from(item)).toList();
- Isso garantiu que os dados vindos do banco fossem convertidos em Mapas nativos do Dart, compatíveis com a HistoryTable.

2. CORREÇÃO DE NULIDADE (Null check operator):
- Tratamos o erro "type 'Null' is not a subtype of type 'List<Map<String, dynamic>>'".
- Causa: Tentativa de renderizar a HistoryTable antes dos dados assíncronos estarem prontos.
- Solução: Adicionamos proteções de nulidade (?? []) e melhoramos o controle do estado _isLoading para garantir que o widget só processe dados válidos.

3. SINCRONIZAÇÃO ENTRE TELAS (Padrão TimesheetUserDetails):
- Usamos a lógica da tela de Auditoria (que estava funcional) para espelhar o comportamento na MonthlyHistoryScreen.
- Padronizamos as chamadas de busca de saldo (getBalanceForMonth) e busca de batidas (fetchCustomRange) para rodarem em paralelo com Future.wait, otimizando a performance.

4. REFATORAÇÃO DE COMPONENTES (MonthPickerField):
- Extraímos o seletor de meses para um componente reutilizável e independente.
- Aplicamos o padrão "Data Down, Events Up": o widget recebe a data por parâmetro e devolve a alteração via callback (onMonthChanged).
- Transformamos o widget em StatelessWidget para evitar conflitos de estado interno e facilitar a manutenção.

---
#### **Nota: 29/01/2026**


1. Foi melhorado a arquitetura de pastas do projeto, para deixar mais limpa.
Movido algumas pastas e componentes para suas pastas correlatas.
layout, ui, utils, components, etc.

2. Foi refatorado o arquivo time_formatter para armazenar mais funções padrões e serem usadas em todo projeto.
Revisado alguns arquivos que ainda não aproveitavam essas classe padrões.


---



*Desenvolvido como parte do curso de ADS - IFPR.*