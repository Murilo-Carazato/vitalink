# API para Hemocentros - VitalInk

Esta API permite que hemocentros sem frontend próprio integrem diretamente com o sistema VitalInk para gerenciar doações.

## Autenticação

### POST /api/blood-center-api/auth

Autentica funcionário do hemocentro e retorna token de acesso.

**Body:**
```json
{
  "email": "funcionario@hemocentro.com",
  "password": "senha123",
  "blood_center_id": 1
}
```

**Resposta de Sucesso:**
```json
{
  "access_token": "1|token_here",
  "token_type": "Bearer",
  "expires_in": 28800,
  "user": {
    "id": 1,
    "name": "João Silva",
    "email": "funcionario@hemocentro.com",
    "blood_center_id": 1
  }
}
```

**Headers de Autenticação:**
Todas as requisições subsequentes devem incluir:
```
Authorization: Bearer {token}
```

## Endpoints Disponíveis

### 1. Obter Doações do Dia

**POST /api/blood-center-api/donations/today**

Retorna todas as doações agendadas para hoje no hemocentro.

**Body:**
```json
{
  "blood_center_id": 1
}
```

**Resposta:**
```json
{
  "date": "2024-07-17",
  "total_donations": 5,
  "donations": [
    {
      "id": 1,
      "donation_token": "abc123xyz",
      "donor_name": "Maria Santos",
      "donor_email": "maria@email.com",
      "blood_type": "O+",
      "donation_time": "09:00:00",
      "status": "SCHEDULED",
      "donor_age_range": "25-35",
      "donor_gender": "F",
      "is_first_time_donor": false,
      "has_encrypted_data": true,
      "created_at": "2024-07-17T08:00:00Z",
      "updated_at": "2024-07-17T08:00:00Z"
    }
  ]
}
```

### 2. Confirmar Doação

**POST /api/blood-center-api/donations/{donationToken}/confirm**

Confirma uma doação agendada.

**Body:**
```json
{
  "blood_center_id": 1,
  "staff_notes": "Doador em boas condições"
}
```

**Resposta:**
```json
{
  "message": "Doação confirmada com sucesso",
  "donation": {
    "id": 1,
    "donation_token": "abc123xyz",
    "status": "CONFIRMED",
    "confirmed_at": "2024-07-17T09:15:00Z",
    "staff_notes": "Doador em boas condições"
  }
}
```

### 3. Completar Doação

**POST /api/blood-center-api/donations/{donationToken}/complete**

Marca uma doação confirmada como concluída.

**Body:**
```json
{
  "blood_center_id": 1,
  "completion_notes": "Doação realizada com sucesso, 450ml coletados"
}
```

**Resposta:**
```json
{
  "message": "Doação concluída com sucesso",
  "donation": {
    "id": 1,
    "donation_token": "abc123xyz",
    "status": "COMPLETED",
    "completed_at": "2024-07-17T09:45:00Z",
    "completion_notes": "Doação realizada com sucesso, 450ml coletados"
  }
}
```

### 4. Obter Notas Médicas

**POST /api/blood-center-api/donations/{donationToken}/medical-notes**

Acessa informações médicas sensíveis da doação (apenas para pessoal autorizado).

**Body:**
```json
{
  "blood_center_id": 1
}
```

**Resposta:**
```json
{
  "donation_token": "abc123xyz",
  "medical_notes": "Notas médicas descriptografadas",
  "health_questions": "Respostas do questionário de saúde",
  "has_encrypted_data": true,
  "encrypted_at": "2024-07-17T08:00:00Z"
}
```

### 5. Estatísticas

**POST /api/blood-center-api/statistics**

Retorna estatísticas do hemocentro por período.

**Body:**
```json
{
  "blood_center_id": 1,
  "period": "today" // "today", "week", "month", "year"
}
```

**Resposta:**
```json
{
  "period": "today",
  "total_donations": 5,
  "by_status": {
    "SCHEDULED": 2,
    "CONFIRMED": 1,
    "COMPLETED": 2,
    "CANCELLED": 0
  },
  "by_blood_type": {
    "O+": 2,
    "A+": 1,
    "B+": 1,
    "AB+": 1
  },
  "first_time_donors": 1,
  "completion_rate": 40.0
}
```

## Códigos de Status

- **200**: Sucesso
- **400**: Dados inválidos
- **401**: Não autorizado
- **403**: Acesso negado
- **404**: Recurso não encontrado
- **500**: Erro interno do servidor

## Segurança

### Autenticação
- Tokens JWT com expiração em 8 horas
- Validação de permissões por hemocentro
- Logs de segurança para todas as operações

### Criptografia
- Dados médicos sensíveis são criptografados automaticamente
- Acesso a informações médicas é logado
- Hashes são usados para busca sem exposição de dados

### Logs de Auditoria
- Todas as operações são registradas
- Acesso a dados sensíveis é monitorado
- Tentativas de acesso não autorizado são bloqueadas

## Exemplos de Uso

### Fluxo Completo de Doação

```bash
# 1. Autenticar
curl -X POST http://localhost:8000/api/blood-center-api/auth \
  -H "Content-Type: application/json" \
  -d '{
    "email": "funcionario@hemocentro.com",
    "password": "senha123",
    "blood_center_id": 1
  }'

# 2. Obter doações do dia
curl -X POST http://localhost:8000/api/blood-center-api/donations/today \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "blood_center_id": 1
  }'

# 3. Confirmar doação
curl -X POST http://localhost:8000/api/blood-center-api/donations/abc123xyz/confirm \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "blood_center_id": 1,
    "staff_notes": "Doador aprovado"
  }'

# 4. Completar doação
curl -X POST http://localhost:8000/api/blood-center-api/donations/abc123xyz/complete \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "blood_center_id": 1,
    "completion_notes": "Doação concluída com sucesso"
  }'
```

## Limitações

- Tokens expiram em 8 horas
- Apenas funcionários admin podem acessar a API
- Dados médicos requerem permissões especiais
- Rate limiting aplicado para prevenir abuso

## Suporte

Para dúvidas ou suporte técnico, contate a equipe de desenvolvimento do VitalInk.
