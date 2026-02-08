import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:vitalink/services/stores/blood_center_store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitalink/src/pages/schedule_donation.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalink/services/helpers/launcher_helper.dart';
import 'package:vitalink/styles.dart';


class BloodCenterDetailsPage extends StatefulWidget {
  static const routeName = '/blood-center-details';

  final int bloodCenterId;

  const BloodCenterDetailsPage({
    Key? key,
    required this.bloodCenterId,
  }) : super(key: key);

  @override
  State<BloodCenterDetailsPage> createState() => _BloodCenterDetailsPageState();
}

class _BloodCenterDetailsPageState extends State<BloodCenterDetailsPage> {
  late BloodCenterStore _bloodCenterStore;

  @override
  void initState() {
    super.initState();
    _bloodCenterStore = Provider.of<BloodCenterStore>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBloodCenterDetails();
    });
  }

  Future<void> _loadBloodCenterDetails() async {
    await _bloodCenterStore.show(widget.bloodCenterId);
  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable:
          Provider.of<BloodCenterStore>(context).selectedBloodCenter,
      builder: (context, bloodCenter, child) {
        final store = Provider.of<BloodCenterStore>(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(bloodCenter?.name ?? 'Detalhes do Hemocentro'),
            centerTitle: true,
          ),
          body: ValueListenableBuilder<bool>(
            valueListenable: store.isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (store.erro.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erro: ${store.erro.value}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBloodCenterDetails,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }
              if (bloodCenter == null) {
                return const Center(child: Text('Nenhum dado disponível'));
              }
              return _buildContent(bloodCenter);
            },
          ),
          floatingActionButton: bloodCenter != null
              ? FloatingActionButton.extended(
                  onPressed: () {
                    context.push('/schedule-donation', extra: {
                      'preSelectedBloodcenterId': bloodCenter.id,
                    });
                  },
                  label: const Text('Agendar Doação'),
                  icon: const Icon(LucideIcons.calendar),
                  backgroundColor: Styles.primary,
                )
              : null,
        );
      },
    );
  }

  Widget _buildContent(BloodCenterModel bloodCenter) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mapa estático ou imagem representativa
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                LucideIcons.mapPin,
                size: 48,
                color: Colors.grey[600],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nome do hemocentro
          Text(
            bloodCenter.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 8),

          // Endereço
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.mapPin),
            title: const Text('Endereço'),
            subtitle: Text(bloodCenter.address),
            onTap: () async {
              try {
                await LauncherHelper.openMap(bloodCenter.address);
              } catch (e) {
                if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
          ),

          // Telefone (se disponível)
          if (bloodCenter.phoneNumber != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.phone),
              title: const Text('Telefone'),
              subtitle: Text(bloodCenter.phoneNumber!),
              onTap: () async {
                try {
                   await LauncherHelper.callPhoneNumber(bloodCenter.phoneNumber!);
                } catch (e) {
                  if(context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
            ),

          // Email (se disponível)
          if (bloodCenter.email != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.mail),
              title: const Text('E-mail'),
              subtitle: Text(bloodCenter.email!),
              trailing: IconButton(
                icon: const Icon(LucideIcons.send),
                onPressed: () async {
                   try {
                     await LauncherHelper.sendEmail(bloodCenter.email!);
                  } catch (e) {
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                tooltip: 'Enviar e-mail',
              ),
            ),

          // Site (se disponível)
          if (bloodCenter.site != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.globe),
              title: const Text('Website'),
              subtitle: Text(bloodCenter.site!),
              onTap: () async {
                 try {
                     await LauncherHelper.openWebsite(bloodCenter.site!);
                  } catch (e) {
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
              },
            ),

          const SizedBox(height: 16),

          // Coordenadas (para debug ou informação adicional)
          Text(
            'Coordenadas: ${bloodCenter.latitude}, ${bloodCenter.longitude}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
