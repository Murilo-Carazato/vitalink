import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalink/services/helpers/database_helper.dart';
import 'package:vitalink/services/helpers/http_client.dart';
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
import 'package:vitalink/src/router/app_router.dart';
import 'package:vitalink/src/settings/settings_controller.dart';
import 'package:vitalink/src/settings/settings_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  
  //App é mantido no modo retrato
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //Cria instância para database
  final db = await DatabaseHelper.instance.database;
  print('Database initialized');

  //Instancia do repositório de usuário
  UserRepository userRepository = UserRepository();

  // Carrega o usuário do banco de dados local antes de inicializar o AuthRepository
  final currentUser = await userRepository.getAuthenticatedUser();
  if (currentUser != null && currentUser.token != null && currentUser.token!.isNotEmpty) {
    print('Found authenticated user: ${currentUser.id}, token: ${currentUser.token!.substring(0, 10)}...');
    MyHttpClient.setToken(currentUser.token!);
  } else {
    print('No authenticated user found');
  }

  // Carrega as configurações de tema
  await settingsController.loadSettings();

  AuthRepository authRepository = AuthRepository();

  final authStore = AuthStore(
    authRepository: authRepository,
    userRepository: userRepository,
  );

  // Instancia e carrega o UserStore
  UserStore userStore = UserStore(repository: userRepository);
  // Já carregamos o usuário acima, então só precisamos configurar o estado
  if (currentUser != null) {
    userStore.state.value = [currentUser];
  }

  final bloodCenterStore = BloodCenterStore(repository: BloodRepository());
  final donationStore =
      DonationStore(repository: DonationRepository(), userStore: userStore);
      
  // Inicializa o AppRouter
  final appRouter = AppRouter(
    userStore: userStore,
    authStore: authStore,
    bloodCenterStore: bloodCenterStore,
    donationStore: donationStore,
    settingsController: settingsController,
  );

  // Definindo estilos de texto padrão para garantir que nunca sejam nulos
  const TextStyle defaultTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  const TextStyle defaultLabelStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color(0xFF646464),
  );
  
  const TextStyle defaultHeadlineSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF333138),
  );
  
  // Estilos de texto para o tema claro
  const TextStyle lightBodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color(0XFF202020),
  );
  
  const TextStyle lightBodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color(0xFF646464),
  );
  
  // Estilos de texto para o tema escuro
  const TextStyle darkBodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color.fromARGB(255, 238, 238, 238),
  );
  
  const TextStyle darkBodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color.fromARGB(255, 196, 196, 196),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authStore),
        ChangeNotifierProvider(create: (_) => userStore),
        ChangeNotifierProvider(create: (_) => bloodCenterStore),
        ChangeNotifierProvider(create: (_) => NearbyStore()),
        ChangeNotifierProvider(create: (_) => donationStore),
      ],
      child: MaterialApp.router(
        title: 'Vitalink',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: const Color(0xFFED1C24),
          dividerTheme: const DividerThemeData(color: Colors.grey),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          // Garantir que os estilos de texto nunca sejam nulos
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontFamily: 'Inter', color: Colors.black, fontWeight: FontWeight.bold, fontSize: 34),
            titleMedium: TextStyle(fontFamily: 'Inter', color: Colors.black, fontWeight: FontWeight.normal, fontSize: 18),
            labelMedium: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(51, 49, 56, 1), fontWeight: FontWeight.normal, fontSize: 16),
            labelSmall: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(166, 166, 166, 1), fontWeight: FontWeight.w600, fontSize: 14),
            headlineMedium: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(166, 166, 166, 1), fontWeight: FontWeight.w600, fontSize: 18),
            headlineSmall: defaultHeadlineSmall,
            bodyMedium: lightBodyMedium,
            bodySmall: lightBodySmall,
            displayMedium: TextStyle(fontFamily: 'Inter', color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
            displaySmall: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(166, 166, 166, 1), fontWeight: FontWeight.w600, fontSize: 14),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: defaultLabelStyle,
            outlineBorder: BorderSide(color: Colors.grey, width: 1.2),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFF7887C), width: 1.2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey, width: 1.2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFED1C24), width: 1.2)),
            errorStyle: TextStyle(fontFamily: 'Inter', color: Color(0xFFED1C24), fontWeight: FontWeight.w400, fontSize: 12),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF222225),
          primaryColor: const Color(0xFFED1C24),
          dividerTheme: const DividerThemeData(color: Color.fromARGB(255, 56, 53, 53)),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF222225)),
          // Garantir que os estilos de texto nunca sejam nulos
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 34),
            titleMedium: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.normal, fontSize: 18),
            labelMedium: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(231, 230, 233, 1), fontWeight: FontWeight.normal, fontSize: 16),
            labelSmall: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(203, 203, 204, 1), fontWeight: FontWeight.w600, fontSize: 14),
            headlineMedium: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(203, 203, 204, 1), fontWeight: FontWeight.w600, fontSize: 18),
            headlineSmall: TextStyle(fontFamily: 'Inter', color: Color.fromARGB(255, 218, 218, 218), fontWeight: FontWeight.w600, fontSize: 16, overflow: TextOverflow.visible),
            bodyMedium: darkBodyMedium,
            bodySmall: darkBodySmall,
            displayMedium: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
            displaySmall: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(166, 166, 166, 1), fontWeight: FontWeight.w600, fontSize: 14),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(fontFamily: 'Inter', color: Color.fromARGB(255, 233, 233, 233), fontWeight: FontWeight.normal, fontSize: 16),
            prefixIconColor: Color.fromARGB(255, 233, 233, 233),
            outlineBorder: BorderSide(color: Color(0xFF3E3F44), width: 1.2),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color.fromARGB(255, 145, 32, 20), width: 1.2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFF3E3F44), width: 1.2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFED1C24), width: 1.2)),
            errorStyle: TextStyle(fontFamily: 'Inter', color: Color(0xFFED1C24), fontWeight: FontWeight.w400, fontSize: 12),
          ),
        ),
        themeMode: settingsController.themeMode,
        routerConfig: appRouter.router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],
      ),
    ),
  );
}
