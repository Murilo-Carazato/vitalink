import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:vitalink/services/stores/auth_store.dart';
import 'package:vitalink/src/pages/reset_password_page.dart';
import 'package:vitalink/styles.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const routeName = '/forgot-password';
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      final success =
          await authStore.forgotPassword(email: _emailController.text.trim());

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email de recuperação enviado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.replace(
            '/reset-password',
            extra: {'email': _emailController.text.trim()},
          );
        } else {
          _showErrorMessage(authStore.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.mailQuestion,
                    size: 64, color: Styles.primary),
                const SizedBox(height: 24),
                Text(
                  'Esqueceu sua senha?',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sem problemas. Insira seu endereço de e-mail abaixo e enviaremos um código para redefinir sua senha.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Digite o email da sua conta',
                    prefixIcon: Icon(LucideIcons.mail),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email é obrigatório';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Consumer<AuthStore>(
                  builder: (context, authStore, child) {
                    return SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: authStore.isLoading ? null : _handleSubmit,
                        icon: authStore.isLoading
                            ? const SizedBox.shrink()
                            : const Icon(LucideIcons.send),
                        label: authStore.isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text('Enviar Email'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Styles.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 