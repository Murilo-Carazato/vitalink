import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:vitalink/services/helpers/http_client.dart';
import 'package:vitalink/services/stores/auth_store.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:vitalink/src/pages/auth.dart';
import 'package:vitalink/styles.dart';

class EmailVerificationPage extends StatefulWidget {
  static const String routeName = '/email-verification';
  
  final String email;
  
  const EmailVerificationPage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Timer? _verificationCheckTimer;

  @override
  void initState() {
    super.initState();
    // Iniciar o timer para verificar o status do email a cada 5 segundos
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkEmailVerificationStatus();
    });
  }

  @override
  void dispose() {
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerificationStatus() async {
    try {
      // Tenta fazer login com as credenciais atuais para verificar o status
      final authStore = Provider.of<AuthStore>(context, listen: false);
      
      // Não mostrar indicador de carregamento para esta verificação em segundo plano
      final result = await authStore.checkEmailVerificationStatus(email: widget.email);
      
      if (result['email_verified'] == true) {
        // Email verificado, redirecionar para a página principal
        _verificationCheckTimer?.cancel();
        
        // Carregar os dados do usuário e navegar
        final userStore = Provider.of<UserStore>(context, listen: false);
        await userStore.loadCurrentUser();
        
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/tab');
        }
      }
    } catch (e) {
      // Ignorar erros silenciosamente - continuaremos tentando
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await MyHttpClient.postString(
        url: '/email/verification-notification',
        headers: MyHttpClient.getHeaders(isJson: true),
        body: {
          'email': widget.email,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = 'Email de verificação enviado com sucesso!';
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao enviar email de verificação. Tente novamente.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goBackToLogin() {
    // Logout e retorno à página de login
    final authStore = Provider.of<AuthStore>(context, listen: false);
    authStore.signOut().then((_) {
      Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação de Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.mailQuestion,
              size: 80,
              color: Styles.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Verifique seu Email',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Enviamos um link de verificação para ${widget.email}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Por favor, verifique seu email para continuar usando o aplicativo.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Após verificar seu email, você será redirecionado automaticamente.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                  textAlign: TextAlign.center,
                ),
              ),
              
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _successMessage!,
                  style: TextStyle(color: Colors.green.shade800),
                  textAlign: TextAlign.center,
                ),
              ),
              
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Reenviar Email de Verificação'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: _goBackToLogin,
              child: const Text('Voltar para o Login'),
            ),
          ],
        ),
      ),
    );
  }
} 