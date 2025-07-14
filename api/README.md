@workspace Provide a detailed explanation of the entire codebase and generate complete documentation in Portuguese

#changes Analyze all changes and generate individual git commit commands in Portuguese for each changed file, following the Conventional Commits standard.  
Example:  
git add file.php; git commit -m "feat(auth): adicionar sistema de autenticação de usuário"

=- Documentação feita usando changes
---

# **Documentação Completa do Projeto**

## **Visão Geral**

Este projeto é uma API desenvolvida em **Laravel** (framework PHP) para gerenciamento de um sistema de hemocentros, usuários e notícias/campanhas. Ele utiliza autenticação via Laravel Sanctum, integração com Firebase, filas, cache, sessões, envio de e-mails, testes automatizados e frontend com TailwindCSS e Vite.

---

## **Estrutura de Pastas**

```
api/
├── app/                   # Código principal da aplicação (controllers, models, etc.)
├── bootstrap/             # Arquivos de bootstrap do Laravel
├── config/                # Arquivos de configuração do Laravel e integrações
├── database/
│   ├── factories/         # Fábricas para geração de dados fake
│   ├── migrations/        # Migrações do banco de dados
│   ├── seeders/           # Seeders para popular o banco
├── public/                # Pasta pública (index.php, .htaccess, favicon, etc.)
├── resources/
│   ├── css/               # Arquivos CSS (Tailwind)
│   ├── js/                # Arquivos JS (bootstrap, app.js)
│   ├── views/             # Views Blade (ex: welcome.blade.php)
├── routes/                # Rotas da aplicação (api.php, web.php, auth.php, console.php)
├── storage/               # Armazenamento de arquivos, logs, cache, sessões, etc.
├── tests/                 # Testes automatizados (Feature, Unit, Pest.php)
├── package.json           # Dependências JS/NPM
├── vite.config.js         # Configuração do Vite
├── phpunit.xml            # Configuração do PHPUnit
└── ...                    # Outros arquivos do Laravel
```

---

## **Principais Funcionalidades**

### 1. **Usuários**

- Cadastro, autenticação (login/logout), atualização e remoção de usuários.
- Suporte a diferentes níveis de administração (`superadmin`, `admin`).
- Associação de usuários a hemocentros.

### 2. **Hemocentros (Blood Centers)**

- Cadastro, listagem, atualização, remoção e visualização de hemocentros.
- Cada hemocentro possui nome, endereço, telefone, localização (latitude/longitude), e-mail e site.

### 3. **Notícias/Campanhas**

- Cadastro, listagem, atualização, remoção e visualização de notícias.
- Cada notícia pode ser do tipo `campaing` (campanha) ou `emergency` (emergência).
- Suporte a imagens e associação ao usuário criador.

### 4. **Autenticação & Segurança**

- Autenticação via **Sanctum** (tokens pessoais).
- Suporte a sessões, cookies, CSRF, e rotas protegidas.
- Reset de senha, verificação de e-mail, e notificações.

### 5. **Infraestrutura**

- **Banco de Dados:** Suporte a SQLite, MySQL, MariaDB, PostgreSQL, SQL Server.
- **Cache:** Suporte a drivers como database, redis, memcached, dynamodb, etc.
- **Filas:** Suporte a jobs assíncronos (database, redis, beanstalkd, sqs).
- **Sessões:** Armazenamento em banco, arquivo, redis, etc.
- **E-mail:** Suporte a SMTP, SES, Postmark, Resend, log, array, failover, roundrobin.
- **Firebase:** Integração para notificações e outros serviços.
- **CORS:** Configuração para permitir acesso do frontend.
- **Testes:** Testes automatizados de autenticação, registro, reset de senha, etc.

---

## **Configurações Importantes**

### **.env**

Configure as variáveis de ambiente para:

- Banco de dados (`DB_CONNECTION`, `DB_DATABASE`, etc.)
- E-mail (`MAIL_MAILER`, `MAIL_HOST`, etc.)
- Firebase (`FIREBASE_CREDENTIALS`)
- Frontend (`FRONTEND_URL`)
- Outros serviços (AWS, Redis, etc.)

### **config/**

- **app.php:** Configurações gerais da aplicação (nome, timezone, locale, etc.)
- **auth.php:** Configuração de autenticação (guards, providers, reset de senha).
- **cache.php:** Configuração dos drivers de cache.
- **database.php:** Configuração dos bancos de dados e Redis.
- **filesystems.php:** Configuração de discos de armazenamento.
- **mail.php:** Configuração dos mailers.
- **queue.php:** Configuração das filas.
- **sanctum.php:** Configuração do Sanctum.
- **services.php:** Chaves de serviços externos (Postmark, SES, Slack, etc.)
- **session.php:** Configuração de sessões.
- **cors.php:** Configuração de CORS.
- **firebase.php:** Configuração do Firebase.

---

## **Banco de Dados**

### **Migrações**

- **users:** Tabela de usuários (nome, e-mail, senha, tipo, hemocentro, etc.)
- **bloodcenters:** Tabela de hemocentros.
- **news:** Tabela de notícias/campanhas.
- **personal_access_tokens:** Tokens do Sanctum.
- **password_reset_tokens:** Tokens de reset de senha.
- **sessions:** Sessões de usuários.
- **cache, cache_locks:** Tabelas para cache.
- **jobs, job_batches, failed_jobs:** Tabelas para filas/jobs.

### **Seeders**

- **DatabaseSeeder:** Cria um usuário admin padrão para testes.

### **Factories**

- **UserFactory:** Gera usuários fake para testes.

---

## **Rotas**

### **api.php**

Rotas da API RESTful, protegidas por autenticação Sanctum quando necessário:

- **Usuários:** `/user`, `/user/login`, `/user/register`, `/user/{id}`
- **Hemocentros:** `/blood-center`, `/blood-center/register`, `/blood-center/{id}`
- **Notícias:** `/news`, `/news/register`, `/news/{id}`

### **web.php**

Rotas web (ex: `/`), inclui rotas de autenticação (auth.php).

### **auth.php**

Rotas para registro, login, reset de senha, verificação de e-mail, logout.

### **console.php**

Comandos customizados para o Artisan.

---

## **Frontend**

- **TailwindCSS:** Utilizado para estilização rápida e responsiva.
- **Vite:** Ferramenta de build e hot reload para assets.
- **resources/views/welcome.blade.php:** Página inicial de boas-vindas, com exemplos de uso do Tailwind e integração com Vite.

---

## **Testes Automatizados**

- **tests/Feature/Auth/**: Testes de autenticação, registro, reset de senha, verificação de e-mail.
- **tests/Feature/ExampleTest.php:** Teste de exemplo.
- **tests/Unit/ExampleTest.php:** Teste unitário de exemplo.
- **tests/Pest.php:** Configuração do PestPHP para testes mais simples e legíveis.

---

## **Comandos Úteis**

- **Rodar servidor local:**  
  `php -S 127.0.0.1:8000 -t public`
- **Rodar migrations:**  
  `php artisan migrate`
- **Rodar seeders:**  
  `php artisan db:seed`
- **Rodar testes:**  
  `php artisan test` ou `vendor/bin/pest`
- **Build frontend:**  
  `npm run build`
- **Desenvolvimento frontend:**  
  `npm run dev`

---

## **Boas Práticas**

- **Variáveis sensíveis** devem ser mantidas no `.env` e nunca versionadas.
- **Chaves de API** e credenciais de serviços externos devem ser protegidas.
- **Testes** devem ser rodados antes de deploys.
- **Migrations** devem ser versionadas e revisadas.
- **Seeders** e **factories** facilitam testes e desenvolvimento local.
- **CORS** deve ser configurado corretamente para evitar problemas de acesso do frontend.
- **Logs** e arquivos temporários não devem ser versionados (veja os .gitignore).

---

## **Exemplo de Fluxo de Cadastro e Login**

1. **Cadastro de Usuário**
   - `POST /user/register` com nome, e-mail, senha.
   - Usuário criado e autenticado.

2. **Login**
   - `POST /user/login` com e-mail e senha.
   - Retorna token de autenticação (Sanctum).

3. **Acesso a rotas protegidas**
   - Enviar token no header `Authorization: Bearer {token}` para acessar rotas protegidas.

---

## **Observações Finais**

- O projeto está pronto para ser expandido com novas entidades, integrações e funcionalidades.
- O uso de **Sanctum** permite tanto autenticação via SPA quanto via API.
- O frontend pode ser desenvolvido separadamente e consumir a API via HTTP.
- O sistema está preparado para produção, mas recomenda-se revisar configurações de segurança, CORS, e-mail e serviços externos antes do deploy.

---

# **Resumo**

Este projeto é uma API robusta, moderna e segura para gerenciamento de hemocentros, usuários e campanhas/notícias, com autenticação, notificações, filas, cache, testes automatizados e frontend integrado. Siga as instruções acima para configurar, rodar e manter o sistema.

---

**Dúvidas ou sugestões? Consulte a documentação do Laravel ([https://laravel.com/docs](https://laravel.com/docs)) ou entre em contato com o responsável pelo projeto.**