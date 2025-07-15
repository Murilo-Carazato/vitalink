import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:vitalink/services/stores/blood_center_store.dart';
import 'package:vitalink/services/stores/donation_store.dart';
import 'package:vitalink/services/stores/nearby_store.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:vitalink/src/components/button_search.dart';
import 'package:vitalink/src/components/button_settings.dart';
import 'package:vitalink/src/pages/blood_center_details.dart';
import 'package:vitalink/src/pages/blood_centers.dart';
import 'package:vitalink/src/pages/guide.dart';
import 'package:vitalink/src/pages/home.dart';
import 'package:vitalink/src/pages/history.dart';
import 'package:vitalink/src/pages/introduction_screen.dart';
import 'package:vitalink/src/pages/auth.dart';
import 'package:vitalink/src/pages/news.dart';
import 'package:vitalink/src/pages/profile.dart';
import 'package:vitalink/src/pages/schedule_donation.dart';
import 'package:vitalink/src/settings/settings_view.dart';
import 'package:vitalink/styles.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'settings/settings_controller.dart';

class MyApp extends StatefulWidget {
  final UserStore userStore;
  final DonationStore donationStore;
  final BloodCenterStore bloodCenterStore;
  final SettingsController settingsController;

  const MyApp({
    super.key,
    required this.settingsController,
    required this.userStore,
    required this.donationStore,
    required this.bloodCenterStore,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Blood Bank',
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'app',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            extensions: const [
              SkeletonizerConfigData(
                  enableSwitchAnimation: true,
                  switchAnimationConfig: SwitchAnimationConfig(
                    switchInCurve: Easing.legacyAccelerate,
                    switchOutCurve: Easing.emphasizedDecelerate,
                    duration: Duration(milliseconds: 300),
                    reverseDuration: Duration(milliseconds: 450),
                  )),
            ],
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            splashColor: Styles.border,
            primaryColor: Styles.primary,
            indicatorColor: Styles.primary,

            //tabBar
            tabBarTheme: const TabBarTheme(
              dividerColor: Colors.white,
              labelColor: Colors.black,
              indicatorColor: Styles.primary,
              overlayColor: WidgetStatePropertyAll(Styles.border),
              splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelColor: Color.fromARGB(255, 107, 104, 104),
              labelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 14),
            ),

            //appBar
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white),

            //checkBox
            checkboxTheme: CheckboxThemeData(
              checkColor: const WidgetStatePropertyAll(Colors.white),
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? Styles.primary : Colors.white,
              ),
              side: const BorderSide(color: Styles.primary, width: 1),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
            ),

            //text
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontFamily: 'Inter', color: Colors.black, fontWeight: FontWeight.bold, fontSize: 34),
              titleMedium: TextStyle(fontFamily: 'Inter', color: Colors.black, fontWeight: FontWeight.normal, fontSize: 18),
              labelMedium: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(51, 49, 56, 1), fontWeight: FontWeight.normal, fontSize: 16),
              labelSmall: TextStyle(fontFamily: 'Inter', color: Styles.gray1, fontWeight: FontWeight.w600, fontSize: 14),
              headlineMedium: TextStyle(fontFamily: 'Inter', color: Styles.gray2, fontWeight: FontWeight.w600, fontSize: 18),
              headlineSmall: TextStyle(fontFamily: 'Inter', color: Styles.gray2, fontWeight: FontWeight.w600, fontSize: 16, overflow: TextOverflow.visible),
              bodyMedium: TextStyle(fontFamily: 'Inter', color: Color(0XFF202020), fontWeight: FontWeight.normal, fontSize: 16),
              bodySmall: TextStyle(fontFamily: 'Inter', color: Color(0xFF646464), fontWeight: FontWeight.normal, fontSize: 16),
              displayMedium: TextStyle(fontFamily: 'Inter', color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
              displaySmall: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(166, 166, 166, 1), fontWeight: FontWeight.w600, fontSize: 14),
            ),

            //textButton
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: const WidgetStatePropertyAll(Styles.primary),
                fixedSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width, 52)),
                shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
                textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 16)),
                overlayColor: const WidgetStatePropertyAll(Color.fromRGBO(255, 38, 14, 1)),
                shadowColor: const WidgetStatePropertyAll(Color.fromRGBO(172, 169, 169, 1)),
              ),
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: Styles.primary,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              actionTextColor: Colors.white,
              elevation: 5,
              contentTextStyle: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              dismissDirection: DismissDirection.horizontal,
              showCloseIcon: true,
              width: MediaQuery.sizeOf(context).width * (83.96 / 100),
              behavior: SnackBarBehavior.floating,
              insetPadding: const EdgeInsets.all(20),
            ),
            dropdownMenuTheme: DropdownMenuThemeData(
              menuStyle: MenuStyle(
                elevation: const WidgetStatePropertyAll(2),
                backgroundColor: const WidgetStatePropertyAll(Styles.border),
                shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                fixedSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width / 3, 120)),
              ),
              textStyle: const TextStyle(fontFamily: 'Inter', color: Color(0xFF646464), fontWeight: FontWeight.normal, fontSize: 16),
              inputDecorationTheme: const InputDecorationTheme(
                labelStyle: TextStyle(fontFamily: 'Inter', color: Color(0xFF646464), fontWeight: FontWeight.normal, fontSize: 16),
                outlineBorder: BorderSide(color: Styles.border, width: 1.2),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFF7887C), width: 1.2)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Styles.border, width: 1.2)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Styles.primary, width: 1.2)),
                errorStyle: TextStyle(fontFamily: 'Inter', color: Styles.primary, fontWeight: FontWeight.w400, fontSize: 12),
              ),
            ),

            //datePicker
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              dividerColor: Styles.border,
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Styles.primary : null),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Styles.primary : null),
              yearStyle: const TextStyle(fontFamily: 'Inter', color: Color(0XFF202020), fontWeight: FontWeight.normal, fontSize: 16),
              weekdayStyle: const TextStyle(fontFamily: 'Inter', color: Color(0XFF202020), fontWeight: FontWeight.bold, fontSize: 16),
              dayStyle: const TextStyle(fontFamily: 'Inter', color: Color(0XFF202020), fontWeight: FontWeight.normal, fontSize: 14),
              headerHeadlineStyle: const TextStyle(fontFamily: 'Inter', color: Color(0XFF202020), fontWeight: FontWeight.normal, fontSize: 22),
              headerHelpStyle: const TextStyle(fontFamily: 'Inter', color: Color(0XFF202020), fontWeight: FontWeight.w600, fontSize: 16),
              yearOverlayColor: const WidgetStatePropertyAll(Styles.border),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              cancelButtonStyle: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width / 3, 40)),
                maximumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width / 2.5, 40)),
                backgroundColor: const WidgetStatePropertyAll(Colors.white),
                side: const WidgetStatePropertyAll(BorderSide(color: Styles.border)),
                foregroundColor: const WidgetStatePropertyAll(Colors.black),
                overlayColor: const WidgetStatePropertyAll(Styles.border),
              ),
              confirmButtonStyle: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width / 3, 40)),
                maximumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width / 2.5, 40)),
              ),
            ),
            textSelectionTheme: const TextSelectionThemeData(cursorColor: Styles.primary, selectionColor: Color.fromRGBO(237, 28, 36, 0.2), selectionHandleColor: Styles.primary),

            //textFormField
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(fontFamily: 'Inter', color: Color(0xFF646464), fontWeight: FontWeight.normal, fontSize: 16),
              outlineBorder: BorderSide(color: Styles.border, width: 1.2),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFF7887C), width: 1.2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Styles.border, width: 1.2)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Styles.primary, width: 1.2)),
              errorStyle: TextStyle(fontFamily: 'Inter', color: Styles.primary, fontWeight: FontWeight.w400, fontSize: 12),
            ),

            //divider
            dividerTheme: const DividerThemeData(color: Styles.border),

            //Essa cor é utilizada pelo widget ExpansionPanelList
            cardColor: Colors.white,

            //popupMenuButton
            popupMenuTheme: const PopupMenuThemeData(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                labelTextStyle: WidgetStatePropertyAll(
                  //bodyMedium com fontSize 14
                  TextStyle(fontFamily: 'Inter', color: Color(0XFF202020), fontWeight: FontWeight.normal, fontSize: 14),
                )),

            //ElevatedButton
            elevatedButtonTheme: const ElevatedButtonThemeData(
              style: ButtonStyle(
                side: WidgetStatePropertyAll(BorderSide(color: Styles.border)),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                foregroundColor: WidgetStatePropertyAll(Color(0XFF202020)),
                minimumSize: WidgetStatePropertyAll(Size(20, 30)),
                textStyle: WidgetStatePropertyAll(
                  //bodyMedium
                  TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 16),
                ),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
            ),
          ),

          darkTheme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            primaryColor: Styles.primary,
            extensions: const [
              SkeletonizerConfigData.dark(
                  enableSwitchAnimation: true,
                  switchAnimationConfig: SwitchAnimationConfig(
                    switchInCurve: Easing.legacyAccelerate,
                    switchOutCurve: Easing.emphasizedDecelerate,
                    duration: Duration(milliseconds: 300),
                    reverseDuration: Duration(milliseconds: 450),
                  )),
            ],
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Styles.darkBackground,

            //tabBar
            tabBarTheme: const TabBarTheme(
              dividerColor: Colors.black,
              labelColor: Colors.white,
              indicatorColor: Styles.primary,
              overlayColor: WidgetStatePropertyAll(Styles.gray2),
              splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelColor: Color.fromARGB(255, 197, 197, 197),
              labelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 14),
            ),

            //appBar
            appBarTheme: const AppBarTheme(backgroundColor: Styles.darkBackground),

            //checkBox
            checkboxTheme: CheckboxThemeData(
              checkColor: const WidgetStatePropertyAll(Colors.white),
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? Styles.primary : Styles.darkBackground,
              ),
              side: const BorderSide(color: Styles.primary, width: 1),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
            ),

            //text
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 34),
              titleMedium: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.normal, fontSize: 18),
              labelMedium: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(231, 230, 233, 1), fontWeight: FontWeight.normal, fontSize: 16),
              labelSmall: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(203, 203, 204, 1), fontWeight: FontWeight.w600, fontSize: 14),
              headlineMedium: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(203, 203, 204, 1), fontWeight: FontWeight.w600, fontSize: 18),
              headlineSmall: TextStyle(fontFamily: 'Inter', color: Color.fromARGB(255, 218, 218, 218), fontWeight: FontWeight.w600, fontSize: 16, overflow: TextOverflow.visible),
              bodyMedium: TextStyle(fontFamily: 'Inter', color: Color.fromARGB(255, 238, 238, 238), fontWeight: FontWeight.normal, fontSize: 16),
              bodySmall: TextStyle(fontFamily: 'Inter', color: Color.fromARGB(255, 196, 196, 196), fontWeight: FontWeight.normal, fontSize: 16),
              displayMedium: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
              displaySmall: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(166, 166, 166, 1), fontWeight: FontWeight.w600, fontSize: 14),
            ),
            textSelectionTheme: const TextSelectionThemeData(cursorColor: Styles.primary, selectionColor: Color.fromRGBO(237, 28, 36, 0.2), selectionHandleColor: Styles.primary),

            //textFormField
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(fontFamily: 'Inter', color: Color.fromARGB(255, 233, 233, 233), fontWeight: FontWeight.normal, fontSize: 16),
              prefixIconColor: Color.fromARGB(255, 233, 233, 233),
              outlineBorder: BorderSide(color: Styles.gray2, width: 1.2),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color.fromARGB(255, 145, 32, 20), width: 1.2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Styles.gray2, width: 1.2)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Styles.primary, width: 1.2)),
              errorStyle: TextStyle(fontFamily: 'Inter', color: Styles.primary, fontWeight: FontWeight.w400, fontSize: 12),
            ),

            //textButton
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: const WidgetStatePropertyAll(Styles.primary),
                fixedSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width, 52)),
                shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
                textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 16)),
                overlayColor: const WidgetStatePropertyAll(Color.fromRGBO(255, 38, 14, 1)),
                shadowColor: const WidgetStatePropertyAll(Color.fromRGBO(172, 169, 169, 1)),
              ),
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: Styles.primary,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              actionTextColor: Colors.white,
              elevation: 5,
              closeIconColor: Colors.white,
              contentTextStyle: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              dismissDirection: DismissDirection.horizontal,
              showCloseIcon: true,
              width: MediaQuery.sizeOf(context).width * (83.96 / 100),
              behavior: SnackBarBehavior.floating,
              insetPadding: const EdgeInsets.all(20),
            ),

            //datePicker
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Styles.darkBackground,
              dividerColor: Styles.gray2,
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Styles.primary : null),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Styles.primary : null),
              yearStyle: const TextStyle(fontFamily: 'Inter', color: Color(0XFFB2B3BD), fontWeight: FontWeight.normal, fontSize: 16),
              weekdayStyle: const TextStyle(fontFamily: 'Inter', color: Color(0XFFB2B3BD), fontWeight: FontWeight.bold, fontSize: 16),
              dayStyle: const TextStyle(fontFamily: 'Inter', color: Color(0XFFB2B3BD), fontWeight: FontWeight.normal, fontSize: 14),
              headerHeadlineStyle: const TextStyle(fontFamily: 'Inter', color: Color(0XFFB2B3BD), fontWeight: FontWeight.normal, fontSize: 22),
              headerHelpStyle: const TextStyle(fontFamily: 'Inter', color: Color(0XFFB2B3BD), fontWeight: FontWeight.w600, fontSize: 16),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : null),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : null),
              yearOverlayColor: const WidgetStatePropertyAll(Styles.gray2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              cancelButtonStyle: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width / 3, 40)),
                maximumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width / 2.5, 40)),
                backgroundColor: const WidgetStatePropertyAll(Color(0xFF222225)),
                side: const WidgetStatePropertyAll(BorderSide(color: Styles.gray1)),
                foregroundColor: const WidgetStatePropertyAll(Color(0xFFB2B3BD)),
                overlayColor: const WidgetStatePropertyAll(Styles.gray1),
              ),
              confirmButtonStyle: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width / 3, 40)),
                maximumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width / 2.5, 40)),
              ),
            ),

            //dropdownButton
            dropdownMenuTheme: DropdownMenuThemeData(
              menuStyle: MenuStyle(
                elevation: const WidgetStatePropertyAll(2),
                backgroundColor: const WidgetStatePropertyAll(Styles.darkBorder),
                shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                fixedSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width / 3, 120)),
              ),
              textStyle: const TextStyle(fontFamily: 'Inter', color: Color.fromARGB(255, 233, 233, 233), fontWeight: FontWeight.normal, fontSize: 16),
              inputDecorationTheme: const InputDecorationTheme(
                labelStyle: TextStyle(fontFamily: 'Inter', color: Color.fromARGB(255, 233, 233, 233), fontWeight: FontWeight.normal, fontSize: 16),
                prefixIconColor: Color.fromARGB(255, 233, 233, 233),
                outlineBorder: BorderSide(color: Styles.gray2, width: 1.2),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color.fromARGB(255, 145, 32, 20), width: 1.2)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Styles.gray2, width: 1.2)),
                errorBorder: UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Styles.primary, width: 1.2)),
              ),
            ),

            //divider
            dividerTheme: const DividerThemeData(color: Color.fromARGB(255, 56, 53, 53)),

            //Essa cor é utilizada pelo widget ExpansionPanelList
            cardColor: Colors.black,

            //popupMenuButton
            popupMenuTheme: const PopupMenuThemeData(
                color: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                labelTextStyle: WidgetStatePropertyAll(
                  //bodyMedium com fontSize 14
                  TextStyle(fontFamily: 'Inter', color: Color.fromARGB(255, 238, 238, 238), fontWeight: FontWeight.normal, fontSize: 14),
                )),

            //ElevatedButton
            elevatedButtonTheme: const ElevatedButtonThemeData(
              style: ButtonStyle(
                side: WidgetStatePropertyAll(BorderSide(color: Color(0xFF3E3F44))),
                backgroundColor: WidgetStatePropertyAll(Styles.darkBackground),
                foregroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 238, 238, 238)),
                minimumSize: WidgetStatePropertyAll(Size(20, 30)),
                textStyle: WidgetStatePropertyAll(
                  //bodyMedium
                  TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 16),
                ),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
            ),
          ),
          themeMode: widget.settingsController.themeMode,
          // initialRoute: '/navbar',

          //NÃO UTILIZAR PARÂMETRO NOMEADO "home:".
          //Para configurar uma rota padrão do app (primária), ir até switch case de onGenerateRoute e alterar retorno do default.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case ScheduleDonationPage.routeName:
                    return ScheduleDonationPage(
                      donationStore: widget.donationStore,
                      bloodCenterStore: widget.bloodCenterStore,
                      userStore: widget.userStore,
                    );
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  case HistoryPage.routeName:
                    return const HistoryPage();
                  case NewsPage.routeName:
                    return const NewsPage();
                  case MyTab.routeName:
                    return MyTab(userStore: widget.userStore);
                  case AuthScreen.routeName:
                    return const AuthScreen();
                  case BloodCenterDetailsPage.routeName:
                    final args = routeSettings.arguments;
                    if (args is Map<String, dynamic>) {
                      return BloodCenterDetailsPage(
                        bloodCenterId: args['bloodCenterId'],
                      );
                    } else {
                      // Show the type and value of the arguments for easier debugging
                      return Scaffold(
                        body: Center(
                          child: Text(
                            'Invalid arguments for BloodCenterDetailsPage:\nType: \\${args?.runtimeType}\nValue: \\${args?.toString()}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  default:
                    //Verifica se usuário já visualizou tela de introdução
                    if (!widget.userStore.state.value.first.viewedTutorial) {
                      return MyIntroductionScreen(userStore: widget.userStore);
                    }

                    // Verifica se o usuário já está logado (tem token)
                    final user = widget.userStore.state.value.first;
                    if (user.token != null && user.token!.isNotEmpty) {
                      // Se tem token, vai direto para a tela principal
                      return MyTab(userStore: widget.userStore);
                    } else {
                      // Se não tem token, vai para a tela de login
                      return const AuthScreen();
                    }
                }
              },
            );
          },
        );
      },
    );
  }
}

class MyTab extends StatefulWidget {
  final UserStore userStore;
  const MyTab({super.key, required this.userStore});

  @override
  State<MyTab> createState() => _MyTabState();

  static const String routeName = '/tab';
}

class _MyTabState extends State<MyTab> {
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Instância do provedor de hemocentros
    final bloodCenterStore = context.watch<BloodCenterStore>();

    //Instância do provedor de usuário
    final userStore = Provider.of<UserStore>(context);

    //Instância do provedor de hemocentros próximos
    final nearbyStore = context.watch<NearbyStore>();

    // Instância do provedor de doações
    final donationStore = context.watch<DonationStore>();

    final titleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24, fontWeight: FontWeight.w600);
    List<Widget> names = [
      Text('Início', style: titleStyle),
      MySearchBar(controller: searchController, bloodCenterStore: bloodCenterStore),
      Text('Perfil', style: titleStyle),
      Text('Guia', style: titleStyle),
    ];
    return PopScope(
      canPop: false,
      child: DefaultTabController(
        length: names.length,
        child: MyNavbar(
          names: names,
          userStore: userStore,
          bloodCenterStore: bloodCenterStore,
          nearbyStore: nearbyStore,
          donationStore: donationStore,
        ),
      ),
    );
  }
}

class MyNavbar extends StatefulWidget {
  final NearbyStore nearbyStore;
  final BloodCenterStore bloodCenterStore;
  final UserStore userStore;
  final DonationStore donationStore;
  final List<Widget> names;
  const MyNavbar({super.key, required this.names, required this.userStore, required this.bloodCenterStore, required this.nearbyStore, required this.donationStore});

  @override
  State<MyNavbar> createState() => _MyNavbarState();
}

class _MyNavbarState extends State<MyNavbar> with SingleTickerProviderStateMixin {
  late final List<Widget> tabViews;
  late final List<Tab> tabs;
  Future requests() async {
    await widget.bloodCenterStore.index(false, '').whenComplete(() async {
      await widget.nearbyStore.syncNearbyBloodCenters(bloodCentersFromApi: widget.bloodCenterStore.state.value);
      await widget.bloodCenterStore.index(true, '');
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requests();
    });
    tabViews = <Widget>[
      HomePage(user: widget.userStore, bloodCenterStore: widget.bloodCenterStore, nearbyStore: widget.nearbyStore, donationStore: widget.donationStore),
      BloodCentersPage(bloodCenterStore: widget.bloodCenterStore),
      ProfilePage(userStore: widget.userStore),
      const GuidePage(),
    ];

    tabs = const <Tab>[
      Tab(
          icon: Icon(
        Icons.home_outlined,
      )),
      Tab(
          icon: Icon(
        Icons.local_hospital_outlined,
      )),
      Tab(
          icon: Icon(
        LucideIcons.user,
      )),
      Tab(
          icon: Icon(
        Icons.help_outline_outlined,
      )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    TabController controller = DefaultTabController.of(context);

    controller.addListener(() => setState(() {}));
    return Scaffold(
      appBar: AppBar(
        title: widget.names[controller.index],
        actions: controller.index != 1 ? const [ButtonSettings()] : null,
      ),
      body: TabBarView(children: tabViews),
      bottomNavigationBar: TabBar(
        tabs: tabs,
      ),
    );
  }
}
