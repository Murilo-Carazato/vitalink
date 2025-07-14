import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vitalink/services/helpers/blood_center_name.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodCenterCardWithOptions extends StatefulWidget {
  final BloodCenterModel bloodCenter;
  const BloodCenterCardWithOptions({super.key, required this.bloodCenter});

  @override
  State<BloodCenterCardWithOptions> createState() =>
      _BloodCenterCardWithOptionsState();
}

class _BloodCenterCardWithOptionsState
    extends State<BloodCenterCardWithOptions> {
  late ScrollController nameScrollController;
  late ScrollController bcScrollController;
  late ScrollController addressScrollController;
  @override
  void initState() {
    nameScrollController = ScrollController();
    bcScrollController = ScrollController();
    addressScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });
    super.initState();
  }

  @override
  void dispose() {
    bcScrollController.dispose();
    nameScrollController.dispose();
    addressScrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (addressScrollController.hasClients) {
      addressScrollController.animateTo(
        addressScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Easing.linear,
      );
    }

    if (bcScrollController.hasClients) {
      bcScrollController.animateTo(
        bcScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Easing.linear,
      );
    }

    if (nameScrollController.hasClients) {
      nameScrollController.animateTo(
        nameScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Easing.linear,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    var name = BloodCenterName(widget.bloodCenter.name);
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Theme.of(context).dividerTheme.color!)),
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: InkWell(
          onTap: () {
            // Navegar para a tela de detalhes do hemocentro
            Navigator.pushNamed(
              context,
              '/blood-center-details',
              arguments: widget.bloodCenter.id,
            );
          },
          child: SizedBox(
            height: 125,
            width: MediaQuery.sizeOf(context).width,
            child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                          child: LayoutBuilder(
                        builder: (context, constraints) => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth * 85 / 100,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: nameScrollController,
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, top: 10),
                                child: Text(
                                  name.formatName().first,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(fontSize: 18),
                                  softWrap: true,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            PopupMenuButton(
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                        enabled:
                                            widget.bloodCenter.site != null,
                                        onTap: () async {
                                          //Abrirá site somente se houver cadastro
                                          if (widget.bloodCenter.site != null &&
                                              widget.bloodCenter.site!
                                                  .isNotEmpty) {
                                            //Navega para site somente se houver um navegador disponível no dispositivo
                                            bool canLaunch = await canLaunchUrl(
                                                Uri.parse(
                                                    widget.bloodCenter.site!));

                                            if (canLaunch) {
                                              await launchUrl(Uri.parse(
                                                  widget.bloodCenter.site!));
                                            }
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.open_in_browser_outlined),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Abrir site',
                                              style: (widget.bloodCenter.site !=
                                                          null &&
                                                      widget.bloodCenter.site!
                                                          .isNotEmpty)
                                                  ? null
                                                  : const TextStyle(
                                                      fontFamily: 'Inter',
                                                      color: Color.fromRGBO(
                                                          172, 169, 169, 1),
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 14),
                                            ),
                                          ],
                                        )),
                                    PopupMenuItem(
                                        onTap: () async {
                                          bool permissionStatus =
                                              await requestPermission();
                                          if (permissionStatus) {
                                            await openMap(
                                                widget.bloodCenter.address);
                                          } else {
                                            openAppSettings();
                                          }
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.location_on),
                                            SizedBox(width: 5),
                                            Text('Ver no mapa'),
                                          ],
                                        )),
                                  ];
                                },
                                icon: const Icon(Icons.more_vert)),
                          ],
                        ),
                      )),
                      Flexible(
                          child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: bcScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          name.formatName().last,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Icon(LucideIcons.mapPin,
                                  color: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .color),
                            ),
                            Flexible(
                                child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: addressScrollController,
                              child: Text(
                                widget.bloodCenter.address,
                                style: Theme.of(context).textTheme.labelSmall!,
                                softWrap: true,
                                maxLines: 2,
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
