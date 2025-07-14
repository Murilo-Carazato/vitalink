import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vitalink/services/helpers/database_helper.dart';
import 'package:vitalink/services/models/user_model.dart';
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
import 'package:provider/provider.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  
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

  //Captura se existe usuário salvo no banco de dados
  List<UserModel> users = await userRepository.getUser();
  UserStore userStore = UserStore(repository: userRepository);
  if (users.isEmpty) {
    //Cria usuário padrão se não houver dados salvos
    userStore.state.value = [
      UserModel(id: 1, name: 'Usuário', birthDate: '25/05/2002', bloodType: 'O-', hasMicropigmentation: false, hasPermanentMakeup: false, hasTattoo: false, viewedTutorial: false)
    ];
    await userRepository.createUser(userStore.state.value.first);
  } else {
    userStore.state.value = users;
  }
  final bloodCenterStore = BloodCenterStore(repository: BloodRepository());
  final donationStore = DonationStore(repository: DonationRepository());

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
