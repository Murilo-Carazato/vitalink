import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:vitalink/services/stores/blood_center_store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitalink/src/pages/schedule_donation.dart';

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

  Future<void> _openMap(BloodCenterModel bloodCenter) async {
    final query = Uri.encodeComponent(bloodCenter.address);
    final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    final uri = Uri.parse(googleUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o mapa')),
        );
      }
    }
  }

  Future<void> _callPhoneNumber(BloodCenterModel bloodCenter) async {
    if (bloodCenter.phoneNumber == null) return;

    final uri = Uri.parse('tel:${bloodCenter.phoneNumber}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível fazer a ligação')),
        );
      }
    }
  }

  Future<void> _openWebsite(BloodCenterModel bloodCenter) async {
    if (bloodCenter.site == null) return;

    String url = bloodCenter.site!;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o site')),
        );
      }
    }
  }

  Future<void> _sendEmail(BloodCenterModel bloodCenter) async {
    if (bloodCenter.email == null) return;

    final uri = Uri.parse('mailto:${bloodCenter.email}?subject=Contato sobre Doação de Sangue');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o app de e-mail')),
        );
      }
    }
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
                    Navigator.pushNamed(
                      context,
                      ScheduleDonationPage.routeName,
                      arguments: {
                        'preSelectedBloodcenterId': bloodCenter.id,
                      },
                    );
                  },
                  label: const Text('Agendar Doação'),
                  icon: const Icon(LucideIcons.calendar),
                  backgroundColor: Colors.red,
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
            onTap: () => _openMap(bloodCenter),
          ),

          // Telefone (se disponível)
          if (bloodCenter.phoneNumber != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.phone),
              title: const Text('Telefone'),
              subtitle: Text(bloodCenter.phoneNumber!),
              onTap: () => _callPhoneNumber(bloodCenter),
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
                onPressed: () => _sendEmail(bloodCenter),
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
              onTap: () => _openWebsite(bloodCenter),
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
