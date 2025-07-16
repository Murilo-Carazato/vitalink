import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalink/services/stores/auth_store.dart';
import 'package:vitalink/services/stores/blood_center_store.dart';
import 'package:vitalink/services/stores/donation_store.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:vitalink/src/pages/auth.dart';
import 'package:vitalink/src/pages/blood_center_details.dart';
import 'package:vitalink/src/pages/email_verification_page.dart';
import 'package:vitalink/src/pages/forgot_password_page.dart';
import 'package:vitalink/src/pages/history.dart';
import 'package:vitalink/src/pages/introduction_screen.dart';
import 'package:vitalink/src/pages/news.dart';
import 'package:vitalink/src/pages/reset_password_page.dart';
import 'package:vitalink/src/pages/schedule_donation.dart';
import 'package:vitalink/src/settings/settings_controller.dart';
import 'package:vitalink/src/settings/settings_view.dart';
import 'package:vitalink/src/app.dart';

class AppRouter {
  final UserStore userStore;
  final AuthStore authStore;
  final BloodCenterStore bloodCenterStore;
  final DonationStore donationStore;
  final SettingsController settingsController;

  AppRouter({
    required this.userStore,
    required this.authStore,
    required this.bloodCenterStore,
    required this.donationStore,
    required this.settingsController,
  });

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    refreshListenable: userStore,
    routes: [
      // Rota inicial que decide para onde ir com base no estado de autenticação
      GoRoute(
        path: '/',
        redirect: (context, state) {
          // Verificar se o usuário está autenticado
          if (userStore.state.value.isNotEmpty &&
              userStore.state.value.first.token != null &&
              userStore.state.value.first.token!.isNotEmpty) {
            
            // Verificar se o usuário já viu o tutorial
            if (!userStore.state.value.first.viewedTutorial) {
              return '/introduction';
            }
            
            return '/tab';
          }
          
          // Se não estiver autenticado, redirecionar para a tela de login
          return '/auth';
        },
      ),
      
      // Rota de autenticação
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      
      // Rota de introdução
      GoRoute(
        path: '/introduction',
        builder: (context, state) => MyIntroductionScreen(userStore: userStore),
      ),
      
      // Rota principal (tab)
      GoRoute(
        path: '/tab',
        builder: (context, state) => MyTab(userStore: userStore),
      ),
      
      // Verificação de email
      GoRoute(
        path: '/email-verification',
        builder: (context, state) {
          final email = state.extra as String? ?? state.uri.queryParameters['email'];
          if (email == null) {
            return const AuthScreen();
          }
          return EmailVerificationPage(email: email);
        },
      ),
      
      // Deep link para email verificado
      GoRoute(
        path: '/email-verified',
        redirect: (context, state) {
          // Carregar os dados do usuário e redirecionar para a página principal
          userStore.loadCurrentUser();
          return '/tab';
        },
      ),
      
      // Esqueci a senha
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Redefinir senha
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.extra as String? ?? state.uri.queryParameters['email'];
          if (email == null) {
            return const ForgotPasswordPage();
          }
          return ResetPasswordPage(email: email);
        },
      ),
      
      // Configurações
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsView(controller: settingsController),
      ),
      
      // Histórico
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
      
      // Notícias
      GoRoute(
        path: '/news',
        builder: (context, state) => const NewsPage(),
      ),
      
      // Detalhes do hemocentro
      GoRoute(
        path: '/blood-center-details',
        builder: (context, state) {
          final bloodCenterId = int.parse(state.uri.queryParameters['id'] ?? '0');
          return BloodCenterDetailsPage(bloodCenterId: bloodCenterId);
        },
      ),
      
      // Agendar doação
      GoRoute(
        path: '/schedule-donation',
        builder: (context, state) {
          final bloodCenterId = int.tryParse(state.uri.queryParameters['bloodCenterId'] ?? '');
          return ScheduleDonationPage(
            donationStore: donationStore,
            bloodCenterStore: bloodCenterStore,
            userStore: userStore,
            preSelectedBloodcenterId: bloodCenterId,
          );
        },
      ),
    ],
    
    // Configuração para deep links
    redirect: (context, state) {
      // Verificar se é um deep link de email verificado
      if (state.uri.toString().startsWith('vitalink://app/email-verified')) {
        return '/email-verified';
      }
      return null;
    },
  );
} 