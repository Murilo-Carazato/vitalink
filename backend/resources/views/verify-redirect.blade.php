<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Verificado</title>
    <!-- Redireciona imediatamente para o app -->
    <meta http-equiv="refresh" content="0;url={{ $deepLink }}">
    <style>
        body {font-family: Arial, Helvetica, sans-serif; padding: 2rem; text-align: center;}
        a {color: #0d6efd; text-decoration: none;}
        a:hover {text-decoration: underline;}
    </style>
</head>
<body>
    <h1>Email verificado com sucesso!</h1>
    <p>Se você não for redirecionado automaticamente, clique no link abaixo:</p>
    <p><a href="{{ $deepLink }}">Abrir aplicativo Vitalink</a></p>
    <p>Você pode fechar esta página com segurança se já estiver no aplicativo.</p>
</body>
</html>
