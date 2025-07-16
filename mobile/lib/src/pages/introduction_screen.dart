import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/services/models/user_model.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:vitalink/src/pages/auth.dart';
import 'package:vitalink/styles.dart';
import 'package:go_router/go_router.dart';

class MyIntroductionScreen extends StatefulWidget {
  final UserStore userStore;
  const MyIntroductionScreen({super.key, required this.userStore});

  @override
  State<MyIntroductionScreen> createState() => _MyIntroductionScreenState();
}

class _MyIntroductionScreenState extends State<MyIntroductionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateColor.transparent,
    );
    return PopScope(
      canPop: false,
      child: IntroductionScreen(
        showBackButton: true,
        //Botão para quando for a última página
        doneStyle: buttonStyle,

        //Botão para quando houver próxima página
        nextStyle: buttonStyle,

        //Botão para quando houver página anterior
        backStyle: buttonStyle,
        back: const Icon(LucideIcons.arrowLeft, color: Styles.primary),
        next: const Icon(LucideIcons.arrowRight, color: Styles.primary),
        done: Text('Entendi', style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Styles.primary)),
        curve: Curves.easeOut,

        //Customização de círculos da contagem de páginas
        dotsDecorator: const DotsDecorator(
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          activeSize: Size(20, 8),
        ),

        //Footer FEMA & Hub Inova FEMA
        globalFooter: const Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 10),
          child: Text('Hub inova fema'),
        ),
        bodyPadding: const EdgeInsets.symmetric(horizontal: 10),
        animationDuration: 500,
        pages: [
          PageViewModel(
            titleWidget: Column(
              children: [
                Text('Bem-vindo(a) ao', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 22)),
                Text('Blood Bank!', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 22))
              ],
            ),
            body: 'Um aplicativo feito para você, doador de sangue que deseja ficar por dentro da comunidade!',
            image: Image.asset(
              './assets/images/flutter_logo.png',
            ),
            decoration: PageDecoration(pageColor: Theme.of(context).scaffoldBackgroundColor),
          ),
          PageViewModel(
            titleWidget: Text('Seus dados', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 22)),
            body: 'Não armazenamos suas informações pessoais! Ao entrar no app, você será cadastrado como "Usuário", podendo alterar se desejar.',
            image: Image.asset(
              './assets/images/flutter_logo.png',
            ),
            decoration: PageDecoration(pageColor: Theme.of(context).scaffoldBackgroundColor),
          ),
          PageViewModel(
            titleWidget: Text('Conclusão', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 22)),
            body: 'Leia o guia de doação e salve vidas!',
            image: Image.asset(
              './assets/images/flutter_logo.png',
            ),
            decoration: PageDecoration(pageColor: Theme.of(context).scaffoldBackgroundColor),
          ),
        ],
        onDone: () async {
          await widget.userStore.updateUser(newUser: widget.userStore.state.value.first.copyWith(viewedTutorial: true)).whenComplete(
            () {
              if (context.mounted) {
                // Navigator.of(context).pushReplacementNamed('/tab');
                context.go('/auth');
              }
            },
          );
        },
        globalHeader: AppBar(title: const Text('BloodBank'), leading: const Icon(LucideIcons.droplets, color: Styles.primary)),
        onChange: (value) {
          //Tratamento async
        },
      ),
    );
  }
}
