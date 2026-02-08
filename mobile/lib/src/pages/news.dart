import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:vitalink/services/helpers/my_dates_formatter.dart';
import 'package:vitalink/services/models/news_model.dart';
import 'package:vitalink/services/repositories/api/news_repository.dart';
import 'package:vitalink/services/repositories/user_repository.dart';
import 'package:vitalink/services/models/user_model.dart';
import 'package:vitalink/services/stores/news_store.dart';
import 'package:vitalink/src/components/button_settings.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  static const routeName = '/news';

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  NewsStore newsStore = NewsStore(repository: NewsRepository());
  List<bool> isPanelOpenCompatible = [];
  List<bool> isPanelOpenGeneral = [];

  @override
  void initState() {
    // Listener para notificações recebidas em foreground (somente mobile por enquanto)
    if (!kIsWeb) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Nova notificação: ${message.notification?.title}');
        if (mounted && message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nova notificação: ${message.notification!.title ?? ''}'),
            ),
          );
        }
      });
    }

    // newsStore.index(false, 0).whenComplete(() {
    //   for (NewsModel element in newsStore.state.value) {
    //     isPanelOpen.add(false);
    //   }
    // });
    super.initState();
  }

  ScrollController scrollController = ScrollController();

  Future<Map<String, dynamic>> loadUserAndNews() async {
    final userBloodType = await getUserBloodType();
    await newsStore.index(false, 0);
    return {
      'userBloodType': userBloodType,
      'news': newsStore.state.value,
    };
  }

  // Busca o tipo sanguíneo do usuário localmente
  Future<String?> getUserBloodType() async {
    final userRepository = UserRepository();
    List<UserModel> users = await userRepository.getUser();
    if (users.isNotEmpty) {
      return users.first.bloodType;
    }
    return null;
  }

  String convertBloodType(String type) {
    switch (type) {
      case 'A+':
        return 'positiveA';
      case 'A-':
        return 'negativeA';
      case 'B+':
        return 'positiveB';
      case 'B-':
        return 'negativeB';
      case 'AB+':
        return 'positiveAB';
      case 'AB-':
        return 'negativeAB';
      case 'O+':
        return 'positiveO';
      case 'O-':
        return 'negativeO';
      default:
        return '';
    }
  }

  // Exemplo simples: só retorna true se for igual (ajuste para lógica real)
  bool isCompatible(String userType, String newsType) {
    return convertBloodType(userType) == newsType;
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notícias', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24, fontWeight: FontWeight.w600)),
        actions: const [ButtonSettings()],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadUserAndNews(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final userBloodType = snapshot.data!['userBloodType'] ?? '';
          final allNews = snapshot.data!['news'] as List<NewsModel>;
          
          print('NEWS PAGE DEBUG:');
          print('User Blood Type: "$userBloodType"');
          print('Total News Fetched: ${allNews.length}');
          
          final compatibleNews = allNews.where((news) {
            final isComp = news.bloodType != null && news.bloodType!.isNotEmpty && isCompatible(userBloodType, news.bloodType!);
            print('Checking News "${news.title}": BloodType="${news.bloodType}", IsCompatible=$isComp');
            return isComp;
          }).toList();
          
          final generalNews = allNews.where((news) => news.bloodType == null || news.bloodType!.isEmpty).toList();

          print('Compatible News Count: ${compatibleNews.length}');
          print('General News Count: ${generalNews.length}');

          // Garante que as listas de controle tenham o tamanho correto
          if (isPanelOpenCompatible.length != compatibleNews.length) {
            isPanelOpenCompatible = List<bool>.filled(compatibleNews.length, false);
          }
          if (isPanelOpenGeneral.length != generalNews.length) {
            isPanelOpenGeneral = List<bool>.filled(generalNews.length, false);
          }

          return SingleChildScrollView(
            child: AnimatedBuilder(
              animation: Listenable.merge([newsStore.state, newsStore.isLoading, newsStore.erro]),
              builder: (context, child) {
                return Flex(
                  direction: Axis.vertical,
                  children: [
                    if (compatibleNews.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Notícias compatíveis com seu sangue', style: textTheme.titleMedium),
                      ),
                      buildNewsPanelList(compatibleNews, textTheme, isPanelOpenCompatible, (index, _) {
                        setState(() {
                          isPanelOpenCompatible[index] = !isPanelOpenCompatible[index];
                        });
                      }),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Notícias gerais', style: textTheme.titleMedium),
                    ),
                    buildNewsPanelList(generalNews, textTheme, isPanelOpenGeneral, (index, _) {
                      setState(() {
                        isPanelOpenGeneral[index] = !isPanelOpenGeneral[index];
                      });
                    }),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildNewsPanelList(
    List<NewsModel> newsList,
    TextTheme textTheme,
    List<bool> isPanelOpen,
    void Function(int, bool) onExpansion,
  ) {
    return Skeletonizer(
      enabled: newsStore.isLoading.value,
      child: ExpansionPanelList(
        materialGapSize: 10,
        elevation: 1,
        animationDuration: const Duration(milliseconds: 600),
        expansionCallback: onExpansion,
        children: [
          for (var i = 0; i < newsList.length; i++)
            ExpansionPanel(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              canTapOnHeader: true,
              isExpanded: isPanelOpen.length > i ? isPanelOpen[i] : false,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 46,
                        color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                      ),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Text(newsList[i].title, style: textTheme.displayMedium),
                      ),
                    ],
                  ),
                );
              },
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text("Publicado em: ${MyDates(createdAt: newsList[i].createdAt!).formatDate}", style: textTheme.displaySmall),
                    ),
                    HtmlWidget(
                      newsList[i].content,
                      textStyle: textTheme.labelSmall,
                    ),
                    const SizedBox(height: 30)
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
