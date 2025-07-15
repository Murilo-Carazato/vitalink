import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:vitalink/src/pages/auth.dart';
import 'package:vitalink/src/pages/introduction_screen.dart';
import 'package:vitalink/src/pages/reset_password_page.dart';
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

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => authStore),
      ChangeNotifierProvider(create: (_) => userStore),
      ChangeNotifierProvider(create: (_) => bloodCenterStore),
      ChangeNotifierProvider(create: (_) => NearbyStore()),
      ChangeNotifierProvider(create: (_) => donationStore),
    ],
    child: MyApp(
      settingsController: settingsController,
      userStore: userStore,
      bloodCenterStore: bloodCenterStore,
      donationStore: donationStore,
    ),
  ));
}
