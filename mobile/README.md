=- Documentação feita usando add file to chat

# **Documentação Completa do Projeto**

## **Visão Geral**

Este projeto é um aplicativo mobile desenvolvido em **Flutter** para gerenciamento de informações de hemocentros, doadores e campanhas/notícias relacionadas à doação de sangue. O app utiliza localização, persistência local, internacionalização, gerenciamento de estado com Provider, integração com APIs e customização visual com fontes e imagens próprias.

---

## **Estrutura de Pastas**

```
mobile/
├── assets/
│   └── images/         # Imagens e ícones do app
├── fonts/
│   └── inter/          # Fontes customizadas (família Inter)
├── lib/
│   ├── main.dart       # Ponto de entrada do app
│   ├── styles.dart     # Estilos globais
│   ├── services/       # Lógica de negócio, helpers, modelos, repositórios, stores
│   │   ├── helpers/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── stores/
│   └── src/
│       ├── app.dart    # Widget principal do app
│       ├── components/ # Componentes reutilizáveis
│       ├── localization/ # Internacionalização
│       ├── pages/      # Telas do app
│       └── settings/   # Configurações e controller de settings
├── pubspec.yaml        # Configurações do projeto e dependências
├── android/            # Projeto Android nativo (configurações, manifest, etc.)
├── ios/                # Projeto iOS nativo (configurações, Info.plist, etc.)
```

---

## **Principais Funcionalidades**

### 1. **Usuários**

- Cadastro, atualização e remoção de usuários.
- Armazenamento local dos dados do usuário.
- Associação de usuários a hemocentros.

### 2. **Hemocentros**

- Listagem de hemocentros próximos via geolocalização.
- Visualização de detalhes (nome, endereço, telefone, localização, e-mail, site).
- Integração com mapas e rotas.

### 3. **Notícias/Campanhas**

- Listagem de campanhas e notícias sobre doação de sangue.
- Destaque para campanhas de emergência.
- Associação de notícias a hemocentros.

### 4. **Permissões & Localização**

- Solicitação de permissões de localização.
- Uso do GPS para encontrar hemocentros próximos.
- Gerenciamento de permissões via `permission_handler`.

### 5. **Internacionalização**

- Suporte a múltiplos idiomas (ex: português e inglês).
- Utilização do pacote `flutter_localizations` e arquivos de tradução.

### 6. **Persistência Local**

- Armazenamento de dados com SQLite (`sqflite`).
- Repositórios para acesso e manipulação dos dados.

### 7. **Gerenciamento de Estado**

- Uso do `provider` para gerenciamento global de estado (usuário, hemocentros, localização).

### 8. **Interface Customizada**

- Fontes customizadas (Inter).
- Imagens e ícones próprios.
- Temas claros e escuros.

---

## **Configurações Importantes**

### **pubspec.yaml**

- **Dependências:**  
  `provider`, `sqflite`, `geolocator`, `permission_handler`, `intl`, `flutter_localizations`, `carousel_slider`, entre outros.
- **Assets:**  
  Registra imagens e fontes customizadas.
- **Fonts:**  
  Família Inter para toda a interface.

### **Info.plist (iOS)**

- Permissões de localização (`NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysUsageDescription`).
- Nome, versão e configurações do app.

### **AndroidManifest.xml (Android)**

- Permissões de localização e internet (descomentar `<uses-permission>` se necessário).
- Configuração de ícone, tema, atividades e queries para intents.

---

## **Banco de Dados Local**

- **Usuários:** Tabela para dados do usuário (nome, nascimento, tipo sanguíneo, etc.).
- **Hemocentros:** Tabela para dados dos hemocentros.
- **Notícias:** Tabela para campanhas/notícias.
- **Configurações:** Tabela para preferências do app.

---

## **Rotas e Navegação**

- **Home:** Tela inicial com resumo e atalhos.
- **Hemocentros:** Lista e detalhes dos hemocentros.
- **Campanhas:** Lista de campanhas/notícias.
- **Perfil:** Dados do usuário e configurações.
- **Configurações:** Preferências do app (tema, idioma, permissões).

---

## **Comandos Úteis**

- **Rodar o app:**  
  `flutter run`
- **Atualizar dependências:**  
  `flutter pub get`
- **Gerar arquivos de internacionalização:**  
  `flutter gen-l10n`
- **Executar testes:**  
  `flutter test`
- **Build para Android:**  
  `flutter build apk`
- **Build para iOS:**  
  `flutter build ios`

---

## **Boas Práticas**

- **Permissões:** Solicite permissões apenas quando necessário e explique ao usuário.
- **Internacionalização:** Sempre use arquivos de tradução para textos exibidos.
- **Gerenciamento de estado:** Use Provider para dados globais e evite variáveis globais.
- **Persistência:** Use repositórios para acesso ao banco de dados, separando lógica de UI.
- **Imagens e fontes:** Registre todos os assets no `pubspec.yaml`.
- **Testes:** Implemente testes unitários para lógica de negócio e helpers.
- **Comentários:** Documente funções, classes e métodos principais.

---

## **Exemplo de Fluxo de Cadastro e Localização**

1. **Primeiro acesso**
   - Usuário abre o app e vê a tela de boas-vindas.
   - App solicita permissão de localização.
   - Usuário concede permissão.

2. **Cadastro**
   - Usuário preenche dados pessoais (nome, nascimento, tipo sanguíneo).
   - Dados são salvos localmente.

3. **Hemocentros próximos**
   - App usa localização para listar hemocentros próximos.
   - Usuário pode ver detalhes e abrir rotas no mapa.

4. **Campanhas**
   - Usuário acessa a aba de campanhas/notícias.
   - Pode visualizar campanhas em destaque e associadas ao seu hemocentro.

---

## **Observações Finais**

- O projeto está pronto para ser expandido com novas funcionalidades, integrações e telas.
- O uso de Provider e repositórios facilita a manutenção e evolução do app.
- O app pode ser publicado tanto para Android quanto para iOS, respeitando as configurações de cada plataforma.
- Recomenda-se revisar permissões, internacionalização e testes antes de publicar.

---

# **Resumo**

Este projeto Flutter é um app moderno, modular e pronto para produção, focado em facilitar a doação de sangue e o acesso a informações de hemocentros e campanhas. Siga as instruções acima para configurar, rodar e manter o sistema.

---

**Dúvidas ou sugestões? Consulte a [documentação oficial do Flutter](https://docs.flutter.dev/) ou entre em contato com o responsável pelo projeto.**