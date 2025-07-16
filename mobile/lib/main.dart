import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalink/services/helpers/database_helper.dart';
import 'package:vitalink/services/helpers/local_notification_helper.dart';
import 'package:vitalink/services/repositories/api/auth_repository.dart';
import 'package:vitalink/services/repositories/api/blood_center_repository.dart';
import 'package:vitalink/services/repositories/api/donation_repository.dart';
import 'package:vitalink/services/repositories/user_repository.dart';
import 'package:vitalink/services/stores/blood_center_store.dart';
import 'package:vitalink/services/stores/auth_store.dart';
import 'package:vitalink/services/stores/donation_store.dart';
import 'package:vitalink/services/stores/nearby_store.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:vitalink/src/app.dart';
import 'package:vitalink/src/settings/settings_controller.dart';
import 'package:vitalink/src/settings/settings_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  
  await LocalNotificationHelper.initialize();

  // Handler para quando o app está em primeiro plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification}');

    LocalNotificationHelper.showNotification(message);
  });

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  
  //App é mantido no modo retrato
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //Cria instância para database
  await DatabaseHelper.instance.database;

  //Instancia do repositório de usuário
  UserRepository userRepository = UserRepository();
  AuthRepository authRepository = AuthRepository();

  final authStore = AuthStore(
    authRepository: authRepository,
    userRepository: userRepository,
  );

  // Instancia e carrega o UserStore
  UserStore userStore = UserStore(repository: userRepository);
  await userStore.loadCurrentUser();

  final bloodCenterStore = BloodCenterStore(repository: BloodRepository());
  final donationStore =
      DonationStore(repository: DonationRepository(), userStore: userStore);

  // Configurar o GoRouter para deep links
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Adiciona logs para debug
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MyApp(
          settingsController: settingsController,
          userStore: userStore,
          bloodCenterStore: bloodCenterStore,
          donationStore: donationStore,
        ),
      ),
      // Adicionar uma rota específica para o deep link de email verificado
      GoRoute(
        path: '/email-verified',
        builder: (context, state) {
          // Carregar dados do usuário após verificação de email
          userStore.loadCurrentUser();
          return MyApp(
            settingsController: settingsController,
            userStore: userStore,
            bloodCenterStore: bloodCenterStore,
            donationStore: donationStore,
          );
        },
      ),
    ],
    // Adicionar um redirecionamento para lidar com o esquema vitalink://app/email-verified
    redirect: (context, state) {
      final uri = state.uri;
      if (uri.scheme == 'vitalink' && uri.host == 'app' && uri.path.contains('email-verified')) {
        return '/email-verified';
      }
      return null;
    },
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => authStore),
      ChangeNotifierProvider(create: (_) => userStore),
      ChangeNotifierProvider(create: (_) => bloodCenterStore),
      ChangeNotifierProvider(create: (_) => NearbyStore()),
      ChangeNotifierProvider(create: (_) => donationStore),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
    ),
  ));
}
