import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:vitalink/services/stores/auth_store.dart';
import 'package:vitalink/services/stores/user_store.dart'; // Added import for UserStore
import 'package:vitalink/styles.dart';
import 'package:vitalink/src/pages/forgot_password_page.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  static const String routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoginMode = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _confirmPasswordController.clear();
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authStore = Provider.of<AuthStore>(context, listen: false);

      late Map<String, dynamic> result;

      if (_isLoginMode) {
        result = await authStore.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        result = await authStore.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          isadmin: 'admin', // Valor padrão
        );
      }

      if (!mounted) return;

      if (result['success']) {
        if (!result['email_verified']) {
          // Redirecionar para a página de verificação de email
          context.go('/email-verification', extra: {'email': _emailController.text.trim()});
        } else {
          // Carrega os dados do novo usuário no UserStore ANTES de navegar
          final userStore = Provider.of<UserStore>(context, listen: false);
          await userStore.loadCurrentUser();
          context.go('/tab');
        }
      } else if (!result['email_verified'] && result.containsKey('email')) {
        // Email não verificado
        context.go('/email-verification', extra: {'email': result['email']});
      } else {
        // Outro erro
        _showErrorMessage(authStore.error);
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleGoogleLogin() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    bool success = await authStore.loginWithGoogle();

    if (success) {
      if (mounted) {
        // Carrega os dados do novo usuário no UserStore ANTES de navegar
        final userStore = Provider.of<UserStore>(context, listen: false);
        await userStore.loadCurrentUser();

        context.go('/tab');
      }
    } else {
      if (mounted) {
        _showErrorMessage(authStore.error);
      }
    }
  }

  void _handleForgotPassword() {
    context.push('/forgot-password');
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != _passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Logo/Título
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Styles.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.heart,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Vitalink',
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: textTheme.bodyLarge?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white70
                            : Styles.gray1,
                      ),
                      children: const [
                        TextSpan(text: 'Doar '),
                        TextSpan(
                          text: 'sangue',
                          style: TextStyle(
                            color: Styles.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' salva vidas!'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Digite seu email',
                            prefixIcon: const Icon(LucideIcons.mail),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: _validateEmail,
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Digite sua senha',
                            prefixIcon: const Icon(LucideIcons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? LucideIcons.eyeOff
                                    : LucideIcons.eye,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: _validatePassword,
                        ),

                        // Confirm Password Field (apenas no cadastro)
                        if (!_isLoginMode) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Senha',
                              hintText: 'Confirme sua senha',
                              prefixIcon: const Icon(LucideIcons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: _validateConfirmPassword,
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Remember Me / Forgot Password
                        if (_isLoginMode) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: Styles.primary,
                                  ),
                                  const Text('Lembrar-me'),
                                ],
                              ),
                              InkWell(
                                onTap: _handleForgotPassword,
                                child: const Text(
                                  'Esqueceu a senha?',
                                  style: TextStyle(
                                    color: Styles.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          const SizedBox(height: 8),
                        ],

                        // Submit Button
                        Consumer<AuthStore>(
                          builder: (context, authStore, _) {
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    authStore.isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Styles.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authStore.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        _isLoginMode
                                            ? 'Entrar'
                                            : 'Cadastrar-se',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Ou',
                                style: TextStyle(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white70
                                      : Styles.gray1,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Consumer<AuthStore>(
                          builder: (context, authStore, _) {
                            return authStore.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Styles.primary),
                                    ),
                                  )
                                : SignInButton(
                                    Buttons.google,
                                    text: 'Entrar com o Google',
                                    onPressed: _handleGoogleLogin,
                                  );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Toggle Mode Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLoginMode
                                  ? 'Não tem uma conta? '
                                  : 'Já tem uma conta? ',
                              style: TextStyle(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white70
                                    : Styles.gray1,
                              ),
                            ),
                            InkWell(
                              onTap: _toggleMode,
                              child: Text(
                                _isLoginMode ? 'Cadastrar-se' : 'Entrar',
                                style: const TextStyle(
                                  color: Styles.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
