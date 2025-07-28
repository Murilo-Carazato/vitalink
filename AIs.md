
# LAUDO DE AUDITORIA TÉCNICA - PROJETO VITALINK

## ANÁLISE DO FLUXO ATUAL

Com base na análise do código fornecido, o fluxo atual do sistema Vitalink pode ser resumido da seguinte forma:

1. **Registro e Autenticação**:
   - Usuários se registram fornecendo email e senha
   - Autenticação tradicional ou via Google (Firebase)
   - Tokens Sanctum são gerados e armazenados no dispositivo

2. **Gerenciamento de Perfil**:
   - Dados como nome, data de nascimento e tipo sanguíneo são armazenados localmente
   - Alguns dados pessoais (nome, email) também são armazenados no servidor

3. **Fluxo de Doação**:
   - Usuários buscam hemocentros (com geolocalização)
   - Agendam doações informando tipo sanguíneo, data/hora e hemocentro
   - Sistema gera um token único para a doação
   - Usuários podem cancelar ou reagendar doações pendentes
   - Usuários podem marcar doações como "concluídas"
   - Histórico de doações é mantido

4. **Notificações e Campanhas**:
   - Hemocentros publicam notícias e campanhas
   - Usuários recebem notificações (Firebase)

## FALHAS LÓGICAS E DE SEGURANÇA ENCONTRADAS

### Falha #1: Violação do Princípio de Privacidade com Armazenamento Excessivo de Dados Pessoais

O projeto declara como objetivo principal a privacidade, armazenando o mínimo de dados no servidor. No entanto:

- O campo `name` é armazenado na tabela `users` no servidor
- O modelo `User.php` inclui campos como `bloodcenter_id` sem distinção clara entre usuários comuns e administradores
- No método `handleGoogleCallback` do `AuthController.php`, o nome do usuário do Google é armazenado no servidor

Esta abordagem contradiz diretamente o princípio de privacidade declarado e aumenta o risco de vazamento de dados pessoais.

### Falha #2: Controle de Acesso Inadequado no Fluxo de Doação

O sistema permite que usuários realizem ações que deveriam ser restritas aos hemocentros:

- O método `completeDonation` no `DonationService.php` permite que o próprio usuário marque uma doação como concluída
- Não há verificação adequada se a pessoa realmente compareceu ao hemocentro
- Qualquer usuário com o token de doação pode confirmar uma doação via API

Esta falha permite a falsificação de registros de doação, comprometendo a integridade do sistema.

### Falha #3: Ausência de Verificação de Disponibilidade na Agenda dos Hemocentros

O método `scheduleDonation` no `DonationRepository.dart` não verifica:

- Se o hemocentro está aberto no horário selecionado
- Se há vagas disponíveis para o horário escolhido
- Se há restrições específicas do hemocentro (tipos de sangue aceitos, etc.)

Isso pode resultar em agendamentos inválidos e frustrações para os usuários.

### Falha #4: Falta de Limites e Validações no Agendamento de Doações

Não há mecanismos para:

- Limitar o número de agendamentos por usuário
- Impedir agendamentos simultâneos
- Verificar o intervalo mínimo entre doações (3 meses para homens, 4 para mulheres)
- Verificar restrições médicas (tatuagens recentes, doenças, etc.)

Um usuário mal-intencionado poderia agendar múltiplas doações e nunca comparecer, prejudicando o sistema.

### Falha #5: Modelo de Autenticação com Falhas de Segurança

- O método `loginWithGoogle` em `auth_repository.dart` realiza uma sequência insegura de autenticação
- Tokens Firebase são enviados diretamente para o backend sem validação adequada
- Não há tratamento adequado para tokens expirados ou revogados
- Ausência de refresh tokens para manter a sessão sem exigir nova autenticação

### Falha #6: Vulnerabilidade na Confirmação de Doações

O endpoint `/donations/{token}/confirm` em `DonationController.php` aceita apenas o token como identificador:

- Qualquer pessoa com acesso ao token pode confirmar/cancelar doações
- Não há verificação se quem está confirmando é realmente o hemocentro designado
- O token é transmitido sem proteções adicionais

### Falha #7: Inconsistência no Modelo de Dados de Doação

O modelo `Donation.php` contém campos conflitantes ou redundantes:

- `reminder_sent` e `reminder_sent_at` são responsabilidades que deveriam estar no cliente
- `staff_notes` é armazenado no servidor, mas não está claro quem tem acesso a essas informações
- O campo `status` permite transições ilógicas (ex: de "cancelled" para "completed")

### Falha #8: Ausência de Mecanismo de Verificação de Email

Apesar de existir o campo `email_verified_at` e a classe `EmailVerificationNotificationController.php`, o sistema não:

- Força a verificação de email antes de permitir agendamentos
- Implementa adequadamente o fluxo de verificação
- Utiliza o middleware `EnsureEmailIsVerified` nas rotas críticas

### Falha #9: Gerenciamento Inadequado de Notificações

O sistema de notificações apresenta falhas:

- Não há controle sobre quais notificações o usuário deseja receber
- As notificações são enviadas sem considerar a relevância para o usuário
- O método `sendNotification` em `FirebaseService.php` não tem mecanismo de retry em caso de falha

### Falha #10: Armazenamento Inseguro de Credenciais Firebase

- Credenciais do Firebase são armazenadas em arquivos no diretório `storage/keys/`
- Não há proteção adequada para esses arquivos sensíveis
- O arquivo `firebase_credentials.json` pode ser exposto acidentalmente

### Falha #11: Inconsistência no Tratamento de Erros

O sistema não possui um tratamento de erros consistente:

- Alguns métodos retornam mensagens genéricas como "Erro ao buscar doações"
- Outros expõem detalhes internos do sistema nos erros
- Não há um log centralizado de erros para análise

### Falha #12: Falta de Validação de Dados Médicos Sensíveis

- O campo `medical_notes` permite texto livre sem validação
- Informações médicas sensíveis são armazenadas sem criptografia
- Não há controle sobre quem pode visualizar essas informações

### Falha #13: Ausência de Mecanismo de Recuperação de Conta

Apesar de existir a classe `PasswordResetLinkController.php`, o fluxo completo de recuperação de senha apresenta falhas:

- Não há proteção contra tentativas excessivas de redefinição
- O token de redefinição é enviado por email sem verificações adicionais
- Não há confirmação após a redefinição da senha

## CONFLITOS COM OS REQUISITOS DO PROJETO

### Conflito #1: Violação do Princípio de Privacidade

O requisito principal é "guardar o mínimo de dados do usuário na API", mas o sistema armazena:
- Nome do usuário (`name` em `users`)
- Notas médicas (`medical_notes` em `donations`)
- Associação direta entre usuário e hemocentro (`bloodcenter_id` em `users`)

### Conflito #2: Interação do Hemocentro

A premissa indica que "não haverá frontend para hemocentros", mas o sistema não implementa:
- Endpoints específicos para uso via Postman/API
- Autenticação adequada para hemocentros via API
- Documentação clara de como os hemocentros devem interagir com o sistema

### Conflito #3: Níveis de Acesso

Os níveis de acesso deveriam ser implementados apenas no backend, mas:
- Há verificações de permissão no frontend (`isadmin` em `auth_store.dart`)
- Não há policies adequadas para todas as entidades (falta `DonationPolicy.php`)
- O controle de acesso é inconsistente entre diferentes controladores

## ANÁLISE CRÍTICA DAS DECISÕES TÉCNICAS (LARAVEL)

### Email Verification

**Decisão atual**: Não implementar verificação de email.
**Análise**: Esta é uma falha crítica de segurança. A verificação de email é essencial para:
- Confirmar a identidade do usuário
- Prevenir criação de contas falsas
- Garantir um canal de comunicação válido para notificações importantes sobre doações

**Recomendação**: Implementar verificação de email obrigatória antes de permitir agendamentos.

### Remember Token

**Decisão atual**: Manter o campo `remember_token`.
**Análise**: O campo é útil para a funcionalidade "Lembrar-me", mas sua implementação atual não segue as melhores práticas:
- Não há rotação de tokens
- Não há expiração definida
- Não há opção para o usuário gerenciar sessões ativas

**Recomendação**: Manter o campo, mas implementar as práticas de segurança mencionadas.

### Sessions Table

**Decisão atual**: Não utilizar a tabela `sessions`.
**Análise**: Com o uso do Sanctum para API tokens, a tabela de sessões não é estritamente necessária. No entanto:
- Sem ela, perde-se a capacidade de rastrear sessões ativas
- Não é possível forçar logout em todos os dispositivos
- Dificulta a detecção de atividades suspeitas

**Recomendação**: Implementar a tabela `sessions` para melhor controle de segurança.

### Jobs/Cache

**Decisão atual**: Não utilizar Jobs ou Cache.
**Análise**: Esta decisão impacta negativamente o desempenho e a experiência do usuário:

**Ausência de Jobs**:
- Envio síncrono de notificações causa atrasos na resposta da API
- Não há mecanismo para lembretes automáticos de doações
- Não há processamento em background para tarefas pesadas

**Ausência de Cache**:
- Lista de hemocentros é sempre carregada do banco de dados
- Informações frequentemente acessadas (como estatísticas) são recalculadas a cada requisição
- Aumento desnecessário de carga no servidor

**Recomendação**: Implementar Jobs para notificações e lembretes, e Cache para dados frequentemente acessados.

## PROPOSTA DE FLUXO LÓGICO CORRIGIDO

### 1. Registro e Autenticação

#### Fluxo Corrigido:
1. **Registro**:
   - Usuário fornece apenas email e senha (dados mínimos no servidor)
   - Sistema envia email de verificação
   - Dados adicionais (nome, data nascimento, tipo sanguíneo) são solicitados após verificação e armazenados APENAS localmente

2. **Autenticação**:
   - Login tradicional ou via Google
   - Implementação de refresh tokens para manter a sessão
   - Opção "Lembrar-me" com rotação de tokens

3. **Verificação de Email**:
   - Obrigatória antes de agendar doações
   - Link de verificação com expiração de 24 horas
   - Reenvio de verificação limitado a 3 tentativas por dia

#### Como resolve as falhas:
- **Falha #1**: Remove o armazenamento de dados pessoais no servidor
- **Falha #5**: Melhora o modelo de autenticação
- **Falha #8**: Implementa verificação de email adequada

### 2. Fluxo de Doação

#### Fluxo Corrigido:
1. **Busca de Hemocentros**:
   - Implementação de cache para lista de hemocentros
   - Adição de informações de horário de funcionamento e tipos de sangue aceitos
   - Filtro por distância e disponibilidade

2. **Agendamento**:
   - Verificação de disponibilidade em tempo real
   - Validação de intervalo mínimo entre doações
   - Limite de agendamentos pendentes por usuário (máximo 1)
   - Verificação de restrições médicas localmente antes do envio

3. **Confirmação**:
   - Geração de QR Code com token único e criptografado
   - Apenas hemocentros autenticados podem confirmar doações
   - Verificação se o hemocentro que confirma é o mesmo do agendamento

4. **Cancelamento/Reagendamento**:
   - Usuário pode cancelar com antecedência mínima (24h)
   - Reagendamento tratado como cancelamento + novo agendamento
   - Limite de cancelamentos por período (3 por mês)

#### Como resolve as falhas:
- **Falha #2**: Restringe ações sensíveis aos hemocentros
- **Falha #3**: Adiciona verificação de disponibilidade
- **Falha #4**: Implementa limites e validações
- **Falha #6**: Melhora a segurança na confirmação
- **Falha #7**: Corrige inconsistências no modelo de dados

### 3. Gerenciamento de Dados Médicos

#### Fluxo Corrigido:
1. **Armazenamento Local**:
   - Dados médicos sensíveis armazenados apenas localmente
   - Criptografia para dados locais sensíveis
   - Sincronização opcional com conta do usuário (criptografada)

2. **Notas Médicas**:
   - Campo `medical_notes` substituído por opções estruturadas
   - Informações sensíveis nunca enviadas ao servidor
   - Hemocentros registram observações em seu próprio sistema

#### Como resolve as falhas:
- **Falha #12**: Melhora a validação e proteção de dados médicos
- **Falha #1**: Reforça o princípio de privacidade

### 4. Sistema de Notificações

#### Fluxo Corrigido:
1. **Preferências de Notificação**:
   - Usuário controla quais notificações deseja receber
   - Opções para lembretes, campanhas e emergências
   - Armazenamento local das preferências

2. **Envio de Notificações**:
   - Implementação de jobs para envio assíncrono
   - Mecanismo de retry em caso de falha
   - Agrupamento de notificações para evitar spam

3. **Lembretes de Doação**:
   - Gerenciados localmente pelo aplicativo
   - Integração com calendário do dispositivo
   - Notificações push apenas como backup

#### Como resolve as falhas:
- **Falha #9**: Melhora o gerenciamento de notificações
- **Falha #7**: Remove campos redundantes do servidor

### 5. Segurança e Proteção de Dados

#### Fluxo Corrigido:
1. **Credenciais e Configurações**:
   - Armazenamento seguro de credenciais usando variáveis de ambiente
   - Remoção de arquivos sensíveis do repositório
   - Implementação de secrets management

2. **Tratamento de Erros**:
   - Sistema centralizado de logging
   - Mensagens de erro padronizadas para o usuário
   - Detalhes técnicos apenas nos logs internos

3. **Recuperação de Conta**:
   - Fluxo seguro de redefinição de senha
   - Limitação de tentativas
   - Notificação em caso de redefinição bem-sucedida

#### Como resolve as falhas:
- **Falha #10**: Melhora a segurança das credenciais
- **Falha #11**: Padroniza o tratamento de erros
- **Falha #13**: Implementa recuperação de conta adequada

### 6. Interação com Hemocentros

#### Fluxo Corrigido:
1. **Autenticação de Hemocentros**:
   - API tokens específicos para hemocentros
   - Autenticação de dois fatores para ações sensíveis
   - Registro de todas as ações realizadas

2. **Endpoints para Hemocentros**:
   - Documentação clara para uso via Postman/API
   - Validação rigorosa de inputs
   - Respostas padronizadas

3. **Confirmação de Doações**:
   - Scanner de QR Code via API
   - Verificação de autenticidade do token
   - Registro de quem confirmou a doação

#### Como resolve as falhas:
- **Conflito #2**: Implementa interação adequada para hemocentros
- **Falha #6**: Melhora a segurança na confirmação de doações

### Reavaliação de Jobs e Cache

Com base no fluxo corrigido, as recomendações para Jobs e Cache são ainda mais relevantes:

#### Jobs Necessários:
1. **Lembretes de Doação**: Envio automático 24h antes da doação agendada
2. **Notificações de Campanhas**: Processamento assíncrono para envio em massa
3. **Verificação de No-Shows**: Identificação automática de usuários que não compareceram
4. **Limpeza de Tokens Expirados**: Manutenção periódica do banco de dados

#### Cache Recomendado:
1. **Lista de Hemocentros**: Cache por região com TTL de 1 hora
2. **Disponibilidade de Horários**: Cache com invalidação por evento (quando um horário é reservado)
3. **Estatísticas de Doação**: Cache diário para dados frequentemente consultados

Estas implementações são essenciais para garantir performance, escalabilidade e experiência do usuário no sistema corrigido.

===


não quero ficar vendo se é nulo ou não, arrume para que o tema nunca seja nulo
exemplo de como estava verificando se era nulo:
import 'package:flutter/material.dart';
import 'package:vitalink/styles.dart';

class ButtonHomePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final void Function()? onTap;
  final double sizeOfCard;
  const ButtonHomePage({super.key, required this.icon, required this.title, this.onTap, required this.sizeOfCard});

  @override
  Widget build(BuildContext context) {
    // Obtém a cor do tema ou usa um valor padrão se for nulo
    final borderColor = Theme.of(context).dividerTheme.color ?? Colors.grey.shade300;
    final backgroundColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.white;
    
    return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: borderColor)),
        color: backgroundColor,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 79,
            width: sizeOfCard,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: Styles.primary,
                  ),
                  const SizedBox(width: 10),
                  Flexible(child: Text(title, style: Theme.of(context).textTheme.headlineSmall ?? TextStyle(fontWeight: FontWeight.w600), softWrap: true))
                ],
              ),
            ),
          ),
        ));
  }
}

===

import 'package:flutter/material.dart';
import 'package:vitalink/styles.dart';

class RichTextLabel extends StatelessWidget {
  final String label;
  const RichTextLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    // Cria um estilo padrão caso o estilo do tema seja nulo
    final TextStyle defaultStyle = TextStyle(
      fontSize: 18,
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.white70 
          : Colors.black87,
    );
    
    // Usa o estilo do tema ou o padrão se for nulo
    var labelStyle = Theme.of(context).inputDecorationTheme.labelStyle?.copyWith(fontSize: 18) 
        ?? defaultStyle;
        
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(text: label, style: labelStyle),
        TextSpan(text: '*', style: labelStyle.copyWith(color: Styles.primary)),
      ],
    ));
  }
}

===

import 'package:flutter/material.dart';
import 'package:vitalink/styles.dart';

class CheckBoxProfile extends StatefulWidget {
  final String label;
  final bool option;
  final void Function(bool?)? onChanged;
  const CheckBoxProfile({super.key, required this.option, required this.label, required this.onChanged});

  @override
  State<CheckBoxProfile> createState() => _CheckBoxProfileState();
}

class _CheckBoxProfileState extends State<CheckBoxProfile> {
  @override
  Widget build(BuildContext context) {
    // Cria um estilo padrão caso o estilo do tema seja nulo
    final TextStyle defaultStyle = TextStyle(
      fontSize: 18,
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.white70 
          : Colors.black87,
    );
    
    // Usa o estilo do tema ou o padrão se for nulo
    var labelStyle = Theme.of(context).inputDecorationTheme.labelStyle?.copyWith(fontSize: 18) 
        ?? defaultStyle;
        
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Checkbox.adaptive(value: widget.option, onChanged: widget.onChanged),
        RichText(
          text: TextSpan(children: [
            TextSpan(text: widget.label, style: labelStyle),
            TextSpan(text: '*', style: labelStyle.copyWith(color: Styles.primary)),
          ]),
        ),
      ],
    );
  }
}


===

igual copilot X Sourcegraph / Cody

nao funcionou, n apareceu nenhum arquivo na analise X CodeScene / ACE

escrever doc web X Mintlify

só analisa o código X Snyk Code

ele so analisou X Codacy

igual copilot X Continue.dev

parecido com copilot, diferencial q explica partes separadas em nós de diagram de árvore X CodeGPT (Judini)

tenho q ficar anexando arquivo por arquivo para documentar X DocuWriter.ai

não me deu opção nenhuma de anexar meu projeto X Graphite Blitzy

igual/pior que o copilot X Refact.ai

horrível, apenas extrai texto do meu projeto X Repomix

igual/pior que o copilot X Cline/RooCode

vê apenas PR X Greptile

free analises, o resto é pago X Sourcery

não existe mais X Autodoc

pago X Swimm

dando erro ao indexar repo X Adrenaline

só pra jetbrain X Sweep

===

igual copilot? instalar CLI com python n deu certo, tentar com docker X Aider

instalar CLI com python n deu certo, tentar com docker README-AI

===

parece promissor V Workik
para arquivos pré commitados é mto bom V CodeRabbit
conheço V Cursor
extensao com tela preta vscode, mas o CLI é muito bom V Qodo
igual/melhor que o copilot VV/X JetBrains AI (FEZ A MAIOR DOCUMENTAÇÃO 2K DE LINHAS)
igual/melhor que o copilot V/X Amazon Q Developer (antigo CodeWhisperer)
conheço V GitHub Copilot (Enterprise / Chat)

=

Google (Vertex AI / AI Studio) vou usar um script o qual já tenho
together AI, Anyscale / Fireworks AI devem funcionar com algum assistente como o copilot
o claude code é tipo o Qodo? indexa meu projeto e me disponiliza qnatos tokens?
aws bedrock eu tenho extensão no vscode

===PROMPTS E PERSONAS PARA UTILIZAR NO FUTURO===

SOLID Rules
# SOLID Design Principles - Coding Assistant Guidelines

When generating, reviewing, or modifying code, follow these guidelines to ensure adherence to SOLID principles:

## 1. Single Responsibility Principle (SRP)

- Each class must have only one reason to change.
- Limit class scope to a single functional area or abstraction level.
- When a class exceeds 100-150 lines, consider if it has multiple responsibilities.
- Separate cross-cutting concerns (logging, validation, error handling) from business logic.
- Create dedicated classes for distinct operations like data access, business rules, and UI.
- Method names should clearly indicate their singular purpose.
- If a method description requires "and" or "or", it likely violates SRP.
- Prioritize composition over inheritance when combining behaviors.

## 2. Open/Closed Principle (OCP)

- Design classes to be extended without modification.
- Use abstract classes and interfaces to define stable contracts.
- Implement extension points for anticipated variations.
- Favor strategy patterns over conditional logic.
- Use configuration and dependency injection to support behavior changes.
- Avoid switch/if-else chains based on type checking.
- Provide hooks for customization in frameworks and libraries.
- Design with polymorphism as the primary mechanism for extending functionality.

## 3. Liskov Substitution Principle (LSP)

- Ensure derived classes are fully substitutable for their base classes.
- Maintain all invariants of the base class in derived classes.
- Never throw exceptions from methods that don't specify them in base classes.
- Don't strengthen preconditions in subclasses.
- Don't weaken postconditions in subclasses.
- Never override methods with implementations that do nothing or throw exceptions.
- Avoid type checking or downcasting, which may indicate LSP violations.
- Prefer composition over inheritance when complete substitutability can't be achieved.

## 4. Interface Segregation Principle (ISP)

- Create focused, minimal interfaces with cohesive methods.
- Split large interfaces into smaller, more specific ones.
- Design interfaces around client needs, not implementation convenience.
- Avoid "fat" interfaces that force clients to depend on methods they don't use.
- Use role interfaces that represent behaviors rather than object types.
- Implement multiple small interfaces rather than a single general-purpose one.
- Consider interface composition to build up complex behaviors.
- Remove any methods from interfaces that are only used by a subset of implementing classes.

## 5. Dependency Inversion Principle (DIP)

- High-level modules should depend on abstractions, not details.
- Make all dependencies explicit, ideally through constructor parameters.
- Use dependency injection to provide implementations.
- Program to interfaces, not concrete classes.
- Place abstractions in a separate package/namespace from implementations.
- Avoid direct instantiation of service classes with 'new' in business logic.
- Create abstraction boundaries at architectural layer transitions.
- Define interfaces owned by the client, not the implementation.

## Implementation Guidelines

- When starting a new class, explicitly identify its single responsibility.
- Document extension points and expected subclassing behavior.
- Write interface contracts with clear expectations and invariants.
- Question any class that depends on many concrete implementations.
- Use factories, dependency injection, or service locators to manage dependencies.
- Review inheritance hierarchies to ensure LSP compliance.
- Regularly refactor toward SOLID, especially when extending functionality.
- Use design patterns (Strategy, Decorator, Factory, Observer, etc.) to facilitate SOLID adherence.

## Warning Signs

- God classes that do "everything"
- Methods with boolean parameters that radically change behavior
- Deep inheritance hierarchies
- Classes that need to know about implementation details of their dependencies
- Circular dependencies between modules
- High coupling between unrelated components
- Classes that grow rapidly in size with new features
- Methods with many parameters

No results



Aa

Rules


Clean Code
Default chat system message


<important_rules> You are in chat mode. If the user asks to make changes to files offer that they can use the Apply Button on the code block, or switch to Agent Mode to make the suggested updates automatically. If needed consisely explain to the user they can switch to agent mode using the Mode Selector dropdown and provide no other details. Always include the language and file name in the info string when you write code blocks. If you are editing "src/main.py" for example, your code block should start with '```python src/main.py' When addressing code modification requests, present a concise code snippet that emphasizes only the necessary changes and uses abbreviated placeholders for unmodified sections. For example: ```language /path/to/file // ... existing code ... {{ modified code here }} // ... existing code ... {{ another modification }} // ... rest of code ... ``` In existing files, you should always restate the function or class that the snippet belongs to: ```language /path/to/file // ... existing code ... function exampleFunction() { // ... existing code ... {{ modified code here }} // ... rest of function ... } // ... rest of code ... ``` Since users have access to their complete file, they prefer reading only the relevant modifications. It's perfectly acceptable to omit unmodified portions at the beginning, middle, or end of files using these "lazy" comments. Only provide the complete file when explicitly requested. Include a concise explanation of changes unless the user specifically asks for code only. </important_rules>
SOLID Rules


# SOLID Design Principles - Coding Assistant Guidelines When generating, reviewing, or modifying code, follow these guidelines to ensure adherence to SOLID principles: ## 1. Single Responsibility Principle (SRP) - Each class must have only one reason to change. - Limit class scope to a single functional area or abstraction level. - When a class exceeds 100-150 lines, consider if it has multiple responsibilities. - Separate cross-cutting concerns (logging, validation, error handling) from business logic. - Create dedicated classes for distinct operations like data access, business rules, and UI. - Method names should clearly indicate their singular purpose. - If a method description requires "and" or "or", it likely violates SRP. - Prioritize composition over inheritance when combining behaviors. ## 2. Open/Closed Principle (OCP) - Design classes to be extended without modification. - Use abstract classes and interfaces to define stable contracts. - Implement extension points for anticipated variations. - Favor strategy patterns over conditional logic. - Use configuration and dependency injection to support behavior changes. - Avoid switch/if-else chains based on type checking. - Provide hooks for customization in frameworks and libraries. - Design with polymorphism as the primary mechanism for extending functionality. ## 3. Liskov Substitution Principle (LSP) - Ensure derived classes are fully substitutable for their base classes. - Maintain all invariants of the base class in derived classes. - Never throw exceptions from methods that don't specify them in base classes. - Don't strengthen preconditions in subclasses. - Don't weaken postconditions in subclasses. - Never override methods with implementations that do nothing or throw exceptions. - Avoid type checking or downcasting, which may indicate LSP violations. - Prefer composition over inheritance when complete substitutability can't be achieved. ## 4. Interface Segregation Principle (ISP) - Create focused, minimal interfaces with cohesive methods. - Split large interfaces into smaller, more specific ones. - Design interfaces around client needs, not implementation convenience. - Avoid "fat" interfaces that force clients to depend on methods they don't use. - Use role interfaces that represent behaviors rather than object types. - Implement multiple small interfaces rather than a single general-purpose one. - Consider interface composition to build up complex behaviors. - Remove any methods from interfaces that are only used by a subset of implementing classes. ## 5. Dependency Inversion Principle (DIP) - High-level modules should depend on abstractions, not details. - Make all dependencies explicit, ideally through constructor parameters. - Use dependency injection to provide implementations. - Program to interfaces, not concrete classes. - Place abstractions in a separate package/namespace from implementations. - Avoid direct instantiation of service classes with 'new' in business logic. - Create abstraction boundaries at architectural layer transitions. - Define interfaces owned by the client, not the implementation. ## Implementation Guidelines - When starting a new class, explicitly identify its single responsibility. - Document extension points and expected subclassing behavior. - Write interface contracts with clear expectations and invariants. - Question any class that depends on many concrete implementations. - Use factories, dependency injection, or service locators to manage dependencies. - Review inheritance hierarchies to ensure LSP compliance. - Regularly refactor toward SOLID, especially when extending functionality. - Use design patterns (Strategy, Decorator, Factory, Observer, etc.) to facilitate SOLID adherence. ## Warning Signs - God classes that do "everything" - Methods with boolean parameters that radically change behavior - Deep inheritance hierarchies - Classes that need to know about implementation details of their dependencies - Circular dependencies between modules - High coupling between unrelated components - Classes that grow rapidly in size with new features - Methods with many parameters

Explore Rules



Chat

Claude 3.5 Sonnet

⏎
Last Session

Create Your Own Assistant
Discover and remix popular assistants, or create your own from scratch

Explore Assistants
Or, create your own assistant from scratch

===

Default chat system message
<important_rules>
  You are in chat mode.

  If the user asks to make changes to files offer that they can use the Apply Button on the code block, or switch to Agent Mode to make the suggested updates automatically.
  If needed consisely explain to the user they can switch to agent mode using the Mode Selector dropdown and provide no other details.

  Always include the language and file name in the info string when you write code blocks.
  If you are editing "src/main.py" for example, your code block should start with '```python src/main.py'

  When addressing code modification requests, present a concise code snippet that
  emphasizes only the necessary changes and uses abbreviated placeholders for
  unmodified sections. For example:

  ```language /path/to/file
  // ... existing code ...

  {{ modified code here }}

  // ... existing code ...

  {{ another modification }}

  // ... rest of code ...
  ```

  In existing files, you should always restate the function or class that the snippet belongs to:

  ```language /path/to/file
  // ... existing code ...

  function exampleFunction() {
    // ... existing code ...

    {{ modified code here }}

    // ... rest of function ...
  }

  // ... rest of code ...
  ```

  Since users have access to their complete file, they prefer reading only the
  relevant modifications. It's perfectly acceptable to omit unmodified portions
  at the beginning, middle, or end of files using these "lazy" comments. Only
  provide the complete file when explicitly requested. Include a concise explanation
  of changes unless the user specifically asks for code only.

</important_rules>

No results



Aa

Rules


Clean Code
Default chat system message


<important_rules> You are in chat mode. If the user asks to make changes to files offer that they can use the Apply Button on the code block, or switch to Agent Mode to make the suggested updates automatically. If needed consisely explain to the user they can switch to agent mode using the Mode Selector dropdown and provide no other details. Always include the language and file name in the info string when you write code blocks. If you are editing "src/main.py" for example, your code block should start with '```python src/main.py' When addressing code modification requests, present a concise code snippet that emphasizes only the necessary changes and uses abbreviated placeholders for unmodified sections. For example: ```language /path/to/file // ... existing code ... {{ modified code here }} // ... existing code ... {{ another modification }} // ... rest of code ... ``` In existing files, you should always restate the function or class that the snippet belongs to: ```language /path/to/file // ... existing code ... function exampleFunction() { // ... existing code ... {{ modified code here }} // ... rest of function ... } // ... rest of code ... ``` Since users have access to their complete file, they prefer reading only the relevant modifications. It's perfectly acceptable to omit unmodified portions at the beginning, middle, or end of files using these "lazy" comments. Only provide the complete file when explicitly requested. Include a concise explanation of changes unless the user specifically asks for code only. </important_rules>
SOLID Rules


# SOLID Design Principles - Coding Assistant Guidelines When generating, reviewing, or modifying code, follow these guidelines to ensure adherence to SOLID principles: ## 1. Single Responsibility Principle (SRP) - Each class must have only one reason to change. - Limit class scope to a single functional area or abstraction level. - When a class exceeds 100-150 lines, consider if it has multiple responsibilities. - Separate cross-cutting concerns (logging, validation, error handling) from business logic. - Create dedicated classes for distinct operations like data access, business rules, and UI. - Method names should clearly indicate their singular purpose. - If a method description requires "and" or "or", it likely violates SRP. - Prioritize composition over inheritance when combining behaviors. ## 2. Open/Closed Principle (OCP) - Design classes to be extended without modification. - Use abstract classes and interfaces to define stable contracts. - Implement extension points for anticipated variations. - Favor strategy patterns over conditional logic. - Use configuration and dependency injection to support behavior changes. - Avoid switch/if-else chains based on type checking. - Provide hooks for customization in frameworks and libraries. - Design with polymorphism as the primary mechanism for extending functionality. ## 3. Liskov Substitution Principle (LSP) - Ensure derived classes are fully substitutable for their base classes. - Maintain all invariants of the base class in derived classes. - Never throw exceptions from methods that don't specify them in base classes. - Don't strengthen preconditions in subclasses. - Don't weaken postconditions in subclasses. - Never override methods with implementations that do nothing or throw exceptions. - Avoid type checking or downcasting, which may indicate LSP violations. - Prefer composition over inheritance when complete substitutability can't be achieved. ## 4. Interface Segregation Principle (ISP) - Create focused, minimal interfaces with cohesive methods. - Split large interfaces into smaller, more specific ones. - Design interfaces around client needs, not implementation convenience. - Avoid "fat" interfaces that force clients to depend on methods they don't use. - Use role interfaces that represent behaviors rather than object types. - Implement multiple small interfaces rather than a single general-purpose one. - Consider interface composition to build up complex behaviors. - Remove any methods from interfaces that are only used by a subset of implementing classes. ## 5. Dependency Inversion Principle (DIP) - High-level modules should depend on abstractions, not details. - Make all dependencies explicit, ideally through constructor parameters. - Use dependency injection to provide implementations. - Program to interfaces, not concrete classes. - Place abstractions in a separate package/namespace from implementations. - Avoid direct instantiation of service classes with 'new' in business logic. - Create abstraction boundaries at architectural layer transitions. - Define interfaces owned by the client, not the implementation. ## Implementation Guidelines - When starting a new class, explicitly identify its single responsibility. - Document extension points and expected subclassing behavior. - Write interface contracts with clear expectations and invariants. - Question any class that depends on many concrete implementations. - Use factories, dependency injection, or service locators to manage dependencies. - Review inheritance hierarchies to ensure LSP compliance. - Regularly refactor toward SOLID, especially when extending functionality. - Use design patterns (Strategy, Decorator, Factory, Observer, etc.) to facilitate SOLID adherence. ## Warning Signs - God classes that do "everything" - Methods with boolean parameters that radically change behavior - Deep inheritance hierarchies - Classes that need to know about implementation details of their dependencies - Circular dependencies between modules - High coupling between unrelated components - Classes that grow rapidly in size with new features - Methods with many parameters

Explore Rules



Chat

Claude 3.5 Sonnet

⏎
Last Session

Create Your Own Assistant
Discover and remix popular assistants, or create your own from scratch

Explore Assistants
Or, create your own assistant from scratch

===

Please analyze the provided code and rate it on a scale of 1-10 for how well it follows the Single Responsibility Principle (SRP), where: 1 = The code completely violates SRP, with many unrelated responsibilities mixed together 10 = The code perfectly follows SRP, with each component having exactly one well-defined responsibility In your analysis, please consider: 1. Primary responsibility: Does each class/function have a single, well-defined purpose? 2. Cohesion: How closely related are the methods and properties within each class? 3. Reason to change: Are there multiple distinct reasons why the code might need to be modified? 4. Dependency relationships: Does the code mix different levels of abstraction or concerns? 5. Naming clarity: Do the names of classes/functions clearly indicate their single responsibility? Please provide: - Numerical rating (1-10) - Brief justification for the rating - Specific examples of SRP violations (if any) - Suggestions for improving SRP adherence - Any positive aspects of the current design Rate more harshly if you find: - Business logic mixed with UI code - Data access mixed with business rules - Multiple distinct operations handled by one method - Classes that are trying to do "everything" - Methods that modify the system in unrelated ways Rate more favorably if you find: - Clear separation of concerns - Classes/functions with focused, singular purposes - Well-defined boundaries between different responsibilities - Logical grouping of related functionality - Easy-to-test components due to their single responsibility

===

Please analyze the provided code and evaluate how well it adheres to each of the SOLID principles on a scale of 1-10, where: 1 = Completely violates the principle 10 = Perfectly implements the principle For each principle, provide: - Numerical rating (1-10) - Brief justification for the rating - Specific examples of violations (if any) - Suggestions for improvement - Positive aspects of the current design ## Single Responsibility Principle (SRP) Rate how well each class/function has exactly one responsibility and one reason to change. Consider: - Does each component have a single, well-defined purpose? - Are different concerns properly separated (UI, business logic, data access)? - Would changes to one aspect of the system require modifications across multiple components? ## Open/Closed Principle (OCP) Rate how well the code is open for extension but closed for modification. Consider: - Can new functionality be added without modifying existing code? - Is there effective use of abstractions, interfaces, or inheritance? - Are extension points well-defined and documented? - Are concrete implementations replaceable without changes to client code? ## Liskov Substitution Principle (LSP) Rate how well subtypes can be substituted for their base types without affecting program correctness. Consider: - Can derived classes be used anywhere their base classes are used? - Do overridden methods maintain the same behavior guarantees? - Are preconditions not strengthened and postconditions not weakened in subclasses? - Are there any type checks that suggest LSP violations? ## Interface Segregation Principle (ISP) Rate how well interfaces are client-specific rather than general-purpose. Consider: - Are interfaces focused and minimal? - Do clients depend only on methods they actually use? - Are there "fat" interfaces that should be split into smaller ones? - Are there classes implementing methods they don't need? ## Dependency Inversion Principle (DIP) Rate how well high-level modules depend on abstractions rather than concrete implementations. Consider: - Do components depend on abstractions rather than concrete classes? - Is dependency injection or inversion of control used effectively? - Are dependencies explicit rather than hidden? - Can implementations be swapped without changing client code? ## Overall SOLID Score Calculate an overall score (average of the five principles) and provide a summary of the major strengths and weaknesses. Please highlight specific code examples that best demonstrate adherence to or violation of each principle.