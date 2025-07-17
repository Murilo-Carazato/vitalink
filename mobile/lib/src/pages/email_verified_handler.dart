import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/stores/user_store.dart';

/// Página invisível que processa o deep-link `vitalink://app/email-verified?token=...`
/// 1. Salva o token
/// 2. Carrega usuário
/// 3. Redireciona para /tab
class EmailVerifiedHandlerPage extends StatefulWidget {
  const EmailVerifiedHandlerPage({super.key, required this.token});

  final String token;

  @override
  State<EmailVerifiedHandlerPage> createState() => _EmailVerifiedHandlerPageState();
}

class _EmailVerifiedHandlerPageState extends State<EmailVerifiedHandlerPage> {
  @override
  void initState() {
    super.initState();
    _processToken();
  }

  Future<void> _processToken() async {
    // Salva token para futuras requisições
    MyHttpClient.setToken(widget.token);

    // Atualiza usuário a partir do backend
    final userStore = context.read<UserStore>();
    await userStore.loadCurrentUser();

    // Navega para tela principal
    if (mounted) {
      context.go('/tab');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Página vazia com progress indicator
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
