import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:vitalink/services/repositories/api/blood_center_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitalink/src/pages/schedule_donation.dart';

class BloodCenterDetailsPage extends StatefulWidget {
  static const routeName = '/blood-center-details';
  
  final int bloodCenterId;
  final BloodRepository repository;
  
  const BloodCenterDetailsPage({
    Key? key, 
    required this.bloodCenterId,
    required this.repository,
  }) : super(key: key);

  @override
  State<BloodCenterDetailsPage> createState() => _BloodCenterDetailsPageState();
}

class _BloodCenterDetailsPageState extends State<BloodCenterDetailsPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  BloodCenterModel? _bloodCenter;
  
  @override
  void initState() {
    super.initState();
    _loadBloodCenterDetails();
  }
  
  Future<void> _loadBloodCenterDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final bloodCenter = await widget.repository.show(widget.bloodCenterId);
      
      setState(() {
        _bloodCenter = bloodCenter;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _openMap() async {
    if (_bloodCenter == null) return;
    
    final query = Uri.encodeComponent(_bloodCenter!.address);
    final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    final uri = Uri.parse(googleUrl);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa')),
      );
    }
  }
  
  Future<void> _callPhoneNumber() async {
    if (_bloodCenter == null || _bloodCenter!.phoneNumber == null) return;
    
    final uri = Uri.parse('tel:${_bloodCenter!.phoneNumber}');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível fazer a ligação')),
      );
    }
  }
  
  Future<void> _openWebsite() async {
    if (_bloodCenter == null || _bloodCenter!.site == null) return;
    
    String url = _bloodCenter!.site!;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o site')),
      );
    }
  }
  
  Future<void> _sendEmail() async {
    if (_bloodCenter == null || _bloodCenter!.email == null) return;
    
    final uri = Uri.parse('mailto:${_bloodCenter!.email}');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível enviar e-mail')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_bloodCenter?.name ?? 'Detalhes do Hemocentro'),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro: $_errorMessage'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBloodCenterDetails,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : _buildContent(),
      floatingActionButton: _bloodCenter != null
        ? FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(
                context,
                ScheduleDonationPage.routeName,
                arguments: _bloodCenter!.id,
              );
            },
            label: const Text('Agendar Doação'),
            icon: const Icon(LucideIcons.calendar),
            backgroundColor: Colors.red,
          )
        : null,
    );
  }
  
  Widget _buildContent() {
    if (_bloodCenter == null) {
      return const Center(child: Text('Nenhum dado disponível'));
    }
    
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
            _bloodCenter!.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          
          const SizedBox(height: 8),
          
          // Endereço
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.mapPin),
            title: const Text('Endereço'),
            subtitle: Text(_bloodCenter!.address),
            onTap: _openMap,
          ),
          
          // Telefone (se disponível)
          if (_bloodCenter!.phoneNumber != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.phone),
              title: const Text('Telefone'),
              subtitle: Text(_bloodCenter!.phoneNumber!),
              onTap: _callPhoneNumber,
            ),
          
          // Email (se disponível)
          if (_bloodCenter!.email != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.mail),
              title: const Text('E-mail'),
              subtitle: Text(_bloodCenter!.email!),
              onTap: _sendEmail,
            ),
          
          // Site (se disponível)
          if (_bloodCenter!.site != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.globe),
              title: const Text('Website'),
              subtitle: Text(_bloodCenter!.site!),
              onTap: _openWebsite,
            ),
          
          const SizedBox(height: 16),
          
          // Coordenadas (para debug ou informação adicional)
          Text(
            'Coordenadas: ${_bloodCenter!.latitude}, ${_bloodCenter!.longitude}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}