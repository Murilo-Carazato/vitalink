# Vita Link

![Vita Link Logo](docs/images/logo.png)

## Sobre o Projeto

Vita Link é uma plataforma que visa aumentar o número de doações de sangue no Brasil, conectando doadores a hemocentros. Principais funcionalidades:

- Cadastro de doadores com informações de tipo sanguíneo
- Mapa de hemocentros próximos
- Notificações sobre campanhas e necessidades urgentes
- Conteúdo educativo sobre doação de sangue
- Informações sobre estoques de sangue em tempo real

## Estrutura do Repositório

```
blood-bank/
├── mobile/     # Aplicativo Flutter
└── api/        # API Laravel
```

## Requisitos

### Mobile
- Flutter 3.10+
- Dart 3.0+
- Android Studio / VS Code
- Serviços de localização e mapas

### Backend
- PHP 8.1+
- Composer
- Laravel 10+
- MySQL 8.0+
- Redis (para notificações)

## Configuração e Instalação

### Backend (API)
```bash
cd api
composer install
cp .env.example .env
# Configure o arquivo .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

### Mobile
```bash
cd mobile
flutter pub get
# Configure as chaves de API para mapas
flutter run
```

## Arquitetura

### Mobile
- **Design Pattern**: Clean Architecture + GetX
- **Mapas**: Google Maps / MapBox
- **Notificações**: Firebase Cloud Messaging
- **Persistência**: Hive
- **Networking**: Dio

### Backend
- **Arquitetura**: Domain-Driven Design
- **Autenticação**: Sanctum com tokens de acesso
- **API**: RESTful
- **Notificações**: Firebase Admin SDK

## Contribuições

Veja nosso [guia de contribuição](CONTRIBUTING.md) para mais detalhes.

## Aviso de Direitos Autorais

© 2025 VitaLink. Todos os direitos reservados.

Este projeto representa trabalho intelectual original criado para fins de portfolio e demonstração de habilidades. O código-fonte está protegido por direitos autorais e não pode ser usado, copiado, modificado ou distribuído sem autorização expressa.

## Licença

Este projeto está licenciado sob a Licença Pública Geral GNU v3.0 (GPL-3.0).

**Importante**: Esta licença requer que qualquer trabalho derivado ou que incorpore este código também seja disponibilizado sob a mesma licença GPL-3.0, com código-fonte aberto. Veja o arquivo [LICENSE](LICENSE) para detalhes completos.
