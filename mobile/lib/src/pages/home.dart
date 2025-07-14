import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/services/models/nearby_model.dart';
import 'package:vitalink/services/repositories/api/blood_center_repository.dart';
import 'package:vitalink/services/stores/blood_center_store.dart';
import 'package:vitalink/services/stores/donation_store.dart';
import 'package:vitalink/services/stores/nearby_store.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:vitalink/src/components/button_home_page.dart';
import 'package:vitalink/src/components/card_home_status/status_card_selector.dart';
import 'package:vitalink/src/components/location_warning.dart';
import 'package:vitalink/src/components/user_header.dart';
import 'package:vitalink/src/pages/blood_center_details.dart';
import 'package:vitalink/src/pages/history.dart';
import 'package:vitalink/src/pages/news.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitalink/src/pages/schedule_donation.dart';

//TODO: arrumar o histórico
//TODO: arrumar o logout

//TODO: estado do card e do "próxima doação" quando for concluida/finalizado
//(hemocentro vai deletar ou atualizar como confirmado dependendo da presença do usuário), 
//tem diferença mas n me atentei e mexi sem commitar. Isso n tem nem no backend

class HomePage extends StatefulWidget {
  final NearbyStore nearbyStore;
  final BloodCenterStore bloodCenterStore;
  final DonationStore donationStore;
  final UserStore user;

  const HomePage({
    super.key,
    required this.user,
    required this.bloodCenterStore,
    required this.nearbyStore,
    required this.donationStore,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    // Carrega próxima doação e estatísticas
    await widget.donationStore.fetchNextDonation();
    await widget.donationStore.fetchDonationHistory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> requestPermission() async {
    Permission permission = Permission.location;
    PermissionStatus permissionStatus = await permission.request();
    if (permissionStatus.isGranted) {
      return true;
    }
    if (permissionStatus.isDenied) {
      requestPermission();
    }
    return false;
  }

  Future<void> openMap(String address) async {
    final query = Uri.encodeComponent(address);
    final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';

    final uri = Uri.parse(googleUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir o mapa.';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildNextDonationCard() {
    return ValueListenableBuilder(
      valueListenable: widget.donationStore.nextDonation,
      builder: (context, nextDonation, child) {
        final textTheme = Theme.of(context).textTheme;

        if (nextDonation == null) {
          return SizedBox(
            width: MediaQuery.of(context).size.width / 1.15,
            height: MediaQuery.of(context).size.height / 3.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próxima Doação',
                  style: textTheme.headlineSmall!.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma doação agendada',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.restorablePushNamed(
                              context, ScheduleDonationPage.routeName);
                        },
                        icon: const Icon(LucideIcons.plus),
                        label: const Text('Agendar Doação'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          width: MediaQuery.of(context).size.width / 1.15,
          height: MediaQuery.of(context).size.height / 3.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Próxima Doação',
                style: textTheme.headlineSmall!.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 10),
                  Text(
                    "Data: ${_formatDate(nextDonation.donationDate)} - ${nextDonation.donationTime}",
                    style: textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hemocentro: ${nextDonation.bloodcenter?.name ?? 'Não informado'}",
                          style: textTheme.headlineSmall,
                        ),
                        Text(
                          "Tipo: ${nextDonation.bloodType}",
                          style: textTheme.headlineSmall,
                        ),
                        Text(
                          "Status: ${_getStatusText(nextDonation.status)}",
                          style: textTheme.headlineSmall?.copyWith(
                            color: _getStatusColor(nextDonation.status),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      bool permissionStatus = await requestPermission();
                      if (permissionStatus &&
                          nextDonation.bloodcenter?.name != null) {
                        await openMap(nextDonation.bloodcenter!.address);
                      } else {
                        openAppSettings();
                      }
                    },
                    icon: const Icon(Icons.location_on_outlined),
                    label: const Text('Ver no mapa'),
                    style: ElevatedButton.styleFrom(
                      elevation: 1,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ).copyWith(
                      splashFactory: NoSplash.splashFactory,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showCancelDonationDialog(nextDonation.donationToken),
                    icon: const Icon(LucideIcons.x),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Agendada';
      case 'confirmed':
        return 'Confirmada';
      case 'completed':
        return 'Concluída';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showCancelDonationDialog(String token) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Doação'),
        content: const Text('Tem certeza que deseja cancelar esta doação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await widget.donationStore.cancelDonation(token);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doação cancelada com sucesso')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${widget.donationStore.error.value}')),
        );
      }
    }
  }

  CarouselSliderController sliderController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        print('Atualizando dados da página inicial...');
        await Future.wait([
          widget.nearbyStore.syncNearbyBloodCenters(
              bloodCentersFromApi: widget.bloodCenterStore.state.value),
          widget.donationStore.fetchNextDonation(),
          // widget.donationStore.fetchStatistics(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card da foto de perfil, nome, idade e tipo sanguíneo
            UserHeader(user: widget.user),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17),
              child: DonationStatusCardSelector(
                donationStore: widget.donationStore,
              ),
            ),
            const Divider(endIndent: 5, indent: 5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: LayoutBuilder(
                  builder: (context, constraints) => Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    children: [
                      ButtonHomePage(
                        icon: LucideIcons.alignJustify,
                        title: 'Histórico',
                        sizeOfCard: constraints.maxWidth * (30.59 / 100),
                        onTap: () {
                          Navigator.restorablePushNamed(
                              context, HistoryPage.routeName);
                        },
                      ),
                      ButtonHomePage(
                        icon: LucideIcons.droplets,
                        title: 'Doar',
                        onTap: () {
                          Navigator.restorablePushNamed(
                              context, ScheduleDonationPage.routeName);
                        },
                        sizeOfCard: constraints.maxWidth * (30.59 / 100),
                      ),
                      ButtonHomePage(
                        icon: LucideIcons.megaphone,
                        title: 'Notícias',
                        onTap: () {
                          Navigator.restorablePushNamed(
                              context, NewsPage.routeName);
                        },
                        sizeOfCard: constraints.maxWidth * (30.59 / 100),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Card de próxima doação
            _buildNextDonationCard(),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.5),
              child: Divider(endIndent: 5, indent: 5),
            ),

            Text(
              'Hemocentros próximos',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),

            AnimatedBuilder(
              animation: Listenable.merge([
                widget.nearbyStore.state,
                widget.nearbyStore.isLoading,
                widget.nearbyStore.userPosition,
                widget.nearbyStore.erro,
                widget.bloodCenterStore.state,
                widget.bloodCenterStore.isLoading,
                widget.bloodCenterStore.erro,
              ]),
              builder: (context, child) {
                // Verifica se há erro de localização
                final errorMsg = widget.nearbyStore.erro.value;
// Verificação mais abrangente para capturar qualquer erro de localização
                if (errorMsg.isNotEmpty &&
                    (errorMsg.contains('localização') ||
                        errorMsg.contains('location') ||
                        errorMsg.contains('GPS') ||
                        errorMsg.contains('serviços de localização'))) {
                  return LocationWarning(
                    nearbyStore: widget.nearbyStore,
                    bloodCenters: widget.bloodCenterStore.state.value,
                  );
                }

                List<NearbyModel> nearbyBCs = widget.nearbyStore.state.value;
                if (widget.bloodCenterStore.isLoading.value ||
                    widget.nearbyStore.isLoading.value) {
                  return Skeletonizer(
                    enabled: true,
                    child: Column(
                      children: List.generate(5, (index) {
                        return const ListTile(
                          title: Text('Hemocenter name goes here...'),
                          subtitle: Text('xxxx km de você'),
                        );
                      }),
                    ),
                  );
                } else if (widget.nearbyStore.state.value.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const Icon(LucideIcons.searchX),
                      const SizedBox(height: 10),
                      Text(
                        "Nenhum hemocentro próximo de você foi encontrado. Certifique-se de que o GPS está ligado.",
                        style: textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }
                // Dentro do ListView.builder na seção de hemocentros próximos
                return ListView.builder(
                  shrinkWrap: true,
                  prototypeItem: child,
                  scrollDirection: Axis.vertical,
                  physics: const ClampingScrollPhysics(parent: ScrollPhysics()),
                  itemCount: nearbyBCs.length,
                  itemBuilder: (context, index) {
                    final nearbyBloodCenter = nearbyBCs[index];
                    return ListTile(
                      title: Text(nearbyBloodCenter.bloodCenter.name),
                      subtitle:
                          Text('${nearbyBloodCenter.distance} km de você'),
                      trailing: const Icon(LucideIcons.chevronRight),
                      onTap: () {
                        // Navegar para a tela de detalhes do hemocentro
                        Navigator.pushNamed(
                          context,
                          '/blood-center-details',
                          arguments: {
                            'bloodCenterId': nearbyBloodCenter.bloodCenter.id,
                            'repository': BloodRepository(),
                          },
                        );
                      },
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
