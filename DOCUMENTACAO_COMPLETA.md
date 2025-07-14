# **Documentação Completa do Projeto VitaLink**

## **Visão Geral do Sistema**

O **VitaLink** é um sistema completo para gerenciamento de doação de sangue, composto por:
- **API Backend** (Laravel/PHP) - Gerencia dados, autenticação e notificações
- **Aplicativo Mobile** (Flutter/Dart) - Interface para doadores e usuários finais

---

## **🔧 Arquitetura do Sistema**

### **Backend (API Laravel)**
```
api/
├── app/                    # Lógica da aplicação
│   ├── Http/Controllers/   # Controladores REST
│   ├── Models/            # Modelos Eloquent
│   ├── Services/          # Serviços de negócio
│   └── Providers/         # Provedores de serviços
├── config/                # Configurações do sistema
├── database/              # Migrações e seeders
├── routes/                # Definição de rotas
└── storage/               # Armazenamento de arquivos
```

### **Mobile (Flutter)**
```
mobile/
├── lib/
│   ├── services/          # Lógica de negócio
│   │   ├── models/        # Modelos de dados
│   │   ├── repositories/  # Acesso a dados
│   │   └── stores/        # Gerenciamento de estado
│   └── src/
│       ├── components/    # Componentes reutilizáveis
│       └── pages/         # Telas do aplicativo
└── assets/                # Recursos (imagens, fontes)
```

---

## **📊 Modelos de Dados**

### **Usuários (Users)**
```php
- id: Identificador único
- name: Nome completo
- email: Email único
- password: Senha criptografada
- isadmin: Tipo (superadmin/admin)
- bloodcenter_id: Hemocentro associado
```

### **Hemocentros (BloodCenters)**
```php
- id: Identificador único
- name: Nome do hemocentro
- address: Endereço completo
- phone_number: Telefone de contato
- latitude/longitude: Coordenadas GPS
- email: Email de contato
- site: Website oficial
```

### **Notícias/Campanhas (News)**
```php
- id: Identificador único
- title: Título da notícia
- content: Conteúdo completo
- image: Imagem em base64
- type: Tipo (campaing/emergency)
- user_id: Usuário criador
```

---

## **🔐 Sistema de Autenticação**

### **Laravel Sanctum**
- Tokens pessoais para autenticação API
- Middleware de proteção de rotas
- Gerenciamento de sessões

### **Fluxo de Autenticação**
1. **Login**: `POST /user/login` → Retorna token
2. **Acesso**: Header `Authorization: Bearer {token}`
3. **Logout**: `DELETE /user/logout` → Revoga token

---

## **🌐 Endpoints da API**

### **Usuários**
```http
POST   /user/register     # Cadastro
POST   /user/login        # Login
DELETE /user/logout       # Logout
GET    /user              # Listar usuários
PUT    /user/{id}         # Atualizar usuário
DELETE /user/{id}         # Remover usuário
```

### **Hemocentros**
```http
GET    /blood-center           # Listar hemocentros
POST   /blood-center/register # Cadastrar hemocentro
GET    /blood-center/{id}      # Detalhes do hemocentro
PUT    /blood-center/{id}      # Atualizar hemocentro
DELETE /blood-center/{id}      # Remover hemocentro
```

### **Notícias**
```http
GET    /news              # Listar notícias (público)
POST   /news/register     # Criar notícia
GET    /news/{id}         # Detalhes da notícia
PUT    /news/{id}         # Atualizar notícia
DELETE /news/{id}         # Remover notícia
```

---

## **🔔 Sistema de Notificações Firebase**

### **Configuração**
- Credenciais em `storage/keys/firebase_credentials.json`
- Certificado SSL em `cacert.pem`
- Service Provider customizado para configuração

### **Tipos de Notificação**
- **Campanhas**: Notificações gerais
- **Emergências**: Notificações por tipo sanguíneo
  - Tópicos: `positiveA`, `negativeA`, `positiveB`, etc.

### **Implementação**
```php
// FirebaseService
public function sendNotification($title, $content, $bloodType, $type)
{
    $message = CloudMessage::withTarget('topic', $bloodType)
        ->withNotification(Notification::create($title, $content))
        ->withData(['key' => $type]);
    
    return $this->messaging->send($message);
}
```

---

## **📱 Aplicativo Mobile**

### **Funcionalidades Principais**
1. **Localização**: Encontrar hemocentros próximos
2. **Perfil**: Gerenciar dados pessoais
3. **Campanhas**: Visualizar notícias e campanhas
4. **Histórico**: Acompanhar doações
5. **Configurações**: Preferências do app

### **Gerenciamento de Estado (Provider)**
```dart
// UserStore - Dados do usuário
// BloodCenterStore - Hemocentros
// NewsStore - Notícias e campanhas
// NearbyStore - Localização e proximidade
```

### **Persistência Local (SQLite)**
- Dados offline do usuário
- Cache de hemocentros
- Histórico de doações
- Configurações do app

---

## **🛠️ Configuração do Ambiente**

### **Backend (Laravel)**
```bash
# Instalar dependências
composer install
npm install

# Configurar ambiente
cp .env.example .env
php artisan key:generate

# Banco de dados
php artisan migrate
php artisan db:seed

# Servidor local
php -S 127.0.0.1:8000 -t public
```

### **Mobile (Flutter)**
```bash
# Instalar dependências
flutter pub get

# Executar app
flutter run

# Build para produção
flutter build apk        # Android
flutter build ios        # iOS
```

---

## **🔧 Configurações Importantes**

### **Variáveis de Ambiente (.env)**
```env
# Aplicação
APP_NAME=VitaLink
APP_URL=http://localhost:8000
FRONTEND_URL=http://172.16.0.21:8080

# Banco de dados
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite

# Firebase
FIREBASE_CREDENTIALS=storage/keys/firebase_credentials.json

# Email
MAIL_MAILER=log
MAIL_FROM_ADDRESS=hello@vitalink.com
```

### **CORS (Cross-Origin)**
```php
// config/cors.php
'allowed_origins' => [env('FRONTEND_URL', 'http://172.16.0.21:8080')]
```

---

## **🔒 Segurança e Permissões**

### **Níveis de Acesso**
- **SuperAdmin**: Acesso total ao sistema
- **Admin**: Gerencia hemocentro específico
- **Usuário**: Acesso básico (mobile)

### **Validações**
- Sanitização de dados de entrada
- Validação de tipos sanguíneos
- Verificação de propriedade de recursos
- Rate limiting em rotas sensíveis

### **Permissões Mobile**
```xml
<!-- Android -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />

<!-- iOS -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Localizar hemocentros próximos</string>
```

---

## **📊 Banco de Dados**

### **Migrações Principais**
1. `create_users_table` - Usuários e autenticação
2. `create_bloodcenters_table` - Hemocentros
3. `create_news_table` - Notícias e campanhas
4. `create_personal_access_tokens_table` - Tokens Sanctum

### **Relacionamentos**
```php
// User -> BloodCenter (belongsTo)
// User -> News (hasMany)
// BloodCenter -> Users (hasMany)
```

---

## **🧪 Testes**

### **Backend (PHPUnit/Pest)**
```bash
php artisan test
```

### **Testes Implementados**
- Autenticação de usuários
- Reset de senha
- Verificação de email
- Registro de usuários

---

## **🚀 Deploy e Produção**

### **Backend**
1. Configurar servidor web (Apache/Nginx)
2. Instalar PHP 8.2+ e extensões
3. Configurar banco de dados
4. Definir variáveis de ambiente
5. Executar migrações

### **Mobile**
1. **Android**: Gerar APK/AAB
2. **iOS**: Build para App Store
3. Configurar certificados de push
4. Testar em dispositivos reais

---

## **📈 Monitoramento e Logs**

### **Laravel Logs**
```php
// storage/logs/laravel.log
Log::info('Firebase notification sent', ['result' => $result]);
Log::error('Firebase error: ' . $e->getMessage());
```

### **Métricas Importantes**
- Taxa de sucesso de notificações
- Tempo de resposta da API
- Erros de autenticação
- Uso de recursos do servidor

---

## **🔄 Fluxos de Trabalho**

### **Cadastro de Emergência**
1. Admin cria notícia tipo "emergency"
2. Sistema valida tipo sanguíneo
3. Firebase envia notificação para tópico específico
4. Usuários recebem push notification
5. Log de envio é registrado

### **Busca de Hemocentros**
1. App solicita permissão de localização
2. Obtém coordenadas GPS do usuário
3. Consulta API com filtros de proximidade
4. Exibe lista ordenada por distância
5. Permite navegação via mapas

---

## **🛡️ Boas Práticas Implementadas**

### **Backend**
- Validação de dados com Form Requests
- Middleware de autenticação
- Paginação e filtros
- Tratamento de exceções
- Logs estruturados

### **Mobile**
- Gerenciamento de estado centralizado
- Persistência offline
- Tratamento de permissões
- Interface responsiva
- Internacionalização

---

## **📋 Comandos Úteis**

### **Laravel**
```bash
# Limpar cache
php artisan cache:clear
php artisan config:clear

# Gerar recursos
php artisan make:controller NomeController
php artisan make:model NomeModel -m

# Banco de dados
php artisan migrate:fresh --seed
php artisan tinker
```

### **Flutter**
```bash
# Limpar build
flutter clean
flutter pub get

# Análise de código
flutter analyze

# Testes
flutter test

# Gerar ícones
flutter packages pub run flutter_launcher_icons:main
```

---

## **🔮 Próximos Passos**

### **Funcionalidades Planejadas**
1. **Chat em tempo real** entre doadores e hemocentros
2. **Gamificação** com pontos e conquistas
3. **Integração com wearables** para monitoramento
4. **IA para predição** de demanda de sangue
5. **Dashboard analytics** para administradores

### **Melhorias Técnicas**
1. **Cache Redis** para performance
2. **Queue jobs** para processamento assíncrono
3. **API versioning** para compatibilidade
4. **Testes automatizados** mais abrangentes
5. **CI/CD pipeline** para deploy automático

---

## **📞 Suporte e Manutenção**

### **Contatos**
- **Desenvolvedor**: [Inserir contato]
- **Documentação**: Este arquivo
- **Repositório**: [Inserir URL do Git]

### **Troubleshooting Comum**
1. **Erro Firebase**: Verificar certificados SSL
2. **Erro CORS**: Configurar origins permitidas
3. **Erro Localização**: Verificar permissões
4. **Erro Database**: Executar migrações

---

**Última atualização**: Janeiro 2025  
**Versão da documentação**: 1.0  
**Status do projeto**: Em desenvolvimento ativo