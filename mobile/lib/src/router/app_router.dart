import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalink/services/stores/auth_store.dart';
import 'package:vitalink/services/stores/blood_center_store.dart';
import 'package:vitalink/services/stores/donation_store.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:vitalink/src/pages/auth.dart';
import 'package:vitalink/src/pages/blood_center_details.dart';
import 'package:vitalink/src/pages/email_verification_page.dart';
import 'package:vitalink/src/pages/email_verified_handler.dart';
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

    refreshListenable: userStore,
    routes: [
      // Rota inicial que decide para onde ir com base no estado de autenticação
      GoRoute(
        path: '/',
        name: '/',
        redirect: (context, state) {
          // Permite deep link de email verificado sem interferir
          if (state.uri.path.startsWith('/email-verified')) {
            return null; // não redireciona, deixa seguir
          }

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
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      
      // Rota de introdução
      GoRoute(
        path: '/introduction',
        name: 'introduction',
        builder: (context, state) => MyIntroductionScreen(userStore: userStore),
      ),
      
      // Rota principal (tab)
      GoRoute(
        path: '/tab',
        name: 'tab',
        builder: (context, state) => MyTab(userStore: userStore),
      ),
      
      // Deep link após email verificado
      GoRoute(
        path: '/email-verified',
        name: 'email-verified',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return EmailVerifiedHandlerPage(token: token);
        },
      ),
      // Deep link com host ('app') gerado pelo backend vitalink://app/email-verified
      GoRoute(
        path: '/app/email-verified',
        name: 'email-verified-host',
        redirect: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return '/email-verified?token=$token';
        },
      ),

      // Verificação de email
      GoRoute(
        path: '/email-verification',
        name: 'email-verification',
        builder: (context, state) {
          final email = state.extra != null 
              ? (state.extra as Map<String, dynamic>)['email'] as String
              : state.uri.queryParameters['email'] ?? '';
              
          return EmailVerificationPage(email: email);
        },
      ),
      
      // Esqueci a senha
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Redefinir senha
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final email = state.extra as String? ?? state.uri.queryParameters['email'] ?? '';
          return ResetPasswordPage(email: email);
        },
      ),
      
      // Configurações
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => SettingsView(controller: settingsController),
      ),
      
      // Histórico
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
      
      // Notícias
      GoRoute(
        path: '/news',
        name: 'news',
        builder: (context, state) => const NewsPage(),
      ),
      
      // Detalhes do hemocentro
      GoRoute(
        path: '/blood-center-details',
        name: 'blood-center-details',
        builder: (context, state) {
          final bloodCenterId = int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 
              (state.extra != null ? (state.extra as Map<String, dynamic>)['bloodCenterId'] as int : 0);
              
          return BloodCenterDetailsPage(bloodCenterId: bloodCenterId);
        },
      ),
      
      // Agendar doação
      GoRoute(
        path: '/schedule-donation',
        name: 'schedule-donation',
        builder: (context, state) {
          final bloodCenterId = int.tryParse(state.uri.queryParameters['bloodCenterId'] ?? '') ?? 
              (state.extra != null ? (state.extra as Map<String, dynamic>)['preSelectedBloodcenterId'] as int? : null);
              
          return ScheduleDonationPage(
            donationStore: donationStore,
            bloodCenterStore: bloodCenterStore,
            userStore: userStore,
            preSelectedBloodcenterId: bloodCenterId,
          );
        },
      ),
    ],
  );
} 