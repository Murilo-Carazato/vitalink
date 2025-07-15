import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitalink/src/components/button_settings.dart';
import 'package:vitalink/services/stores/donation_store.dart';
import 'package:vitalink/services/models/donation_model.dart';
import 'package:vitalink/styles.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  static const routeName = '/history';

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? selectedFilter;
  late DonationStore donationStore;

  @override
  void initState() {
    super.initState();
    donationStore = Provider.of<DonationStore>(context, listen: false);
    _loadDonationHistory();
  }

  Future<void> _openMap(String address) async {
    final query = Uri.encodeComponent(address);
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

  void _loadDonationHistory() async {
    await donationStore.fetchDonationHistory();
  }

  void _filterDonations(String? filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  void _showCompleteDialog(DonationModel donation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Concluir Doação'),
        content: const Text('Tem certeza que deseja marcar esta doação como concluída?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final success =
                  await donationStore.completeDonation(donation.donationToken);
              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                      content: Text('Doação marcada como concluída')),
                );
              }
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(DonationModel donation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Doação'),
        content: const Text('Tem certeza que deseja cancelar esta doação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final success = await donationStore.cancelDonation(donation.donationToken);
              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Doação cancelada com sucesso')),
                );
              }
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Histórico',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [ButtonSettings()],
      ),
      body: Consumer<DonationStore>(
        builder: (context, store, child) {
          if (store.isLoading && store.donations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.error.isNotEmpty) {
            return Center(child: Text('Erro: ${store.error}'));
          }

          final filteredDonations = store.getFilteredDonations(status: selectedFilter);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Filtrar",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(width: 13),
                    _buildFilterButton('completed', 'Concluído', Colors.green),
                    const SizedBox(width: 13),
                    _buildFilterButton('cancelled', 'Cancelado', Colors.red),
                    const SizedBox(width: 13),
                    _buildFilterButton('scheduled', 'Pendente', Colors.orange),
                  ],
                ),
                const SizedBox(height: 44),
                if (store.isLoading && store.donations.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (filteredDonations.isEmpty && !store.isLoading)
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma doação encontrada',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDonations.length,
                    itemBuilder: (context, index) {
                      final donation = filteredDonations[index];
                      return _buildDonationCard(donation, textTheme);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(String filter, String label, Color color) {
    final isSelected = selectedFilter == filter;
    
    return SizedBox(
      width: 90,
      height: 37,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isSelected ? color : Styles.border),
          backgroundColor: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => _filterDonations(isSelected ? null : filter),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDonationCard(DonationModel donation, TextTheme textTheme) {
    final statusColor = donation.statusColor;
    final statusText = donation.statusDisplayName;
    final statusIcon = donation.statusIcon;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Status header
          Container(
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: statusColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Donation details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Agendado: ${donation.donationDate.day}/${donation.donationDate.month}/${donation.donationDate.year}",
                      style: textTheme.labelSmall,
                    ),
                    Text(
                      "Horário: ${donation.donationTime}",
                      style: textTheme.labelSmall,
                    ),
                    if (donation.status.toLowerCase() == 'completed')
                      Text(
                        "Realizado: ${donation.donationDate.day}/${donation.donationDate.month}/${donation.donationDate.year}",
                        style: textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 21),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tipo sanguíneo: ${donation.bloodType}",
                      style: textTheme.labelSmall,
                    ),
                    if (donation.donorGender != null)
                      Text(
                        "Gênero: ${donation.donorGender}",
                        style: textTheme.labelSmall,
                      ),
                    if (donation.donorAgeRange != null)
                      Text(
                        "Idade: ${donation.donorAgeRange}",
                        style: textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          
          // Location info
          InkWell(
            onTap: () => _openMap(donation.bloodcenter!.address),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 25),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Endereço: ${donation.bloodcenter!.address}",
                        style: textTheme.labelSmall,
                      ),
                      if (donation.medicalNotes != null && donation.medicalNotes!.isNotEmpty)
                        Text(
                          "Observações: ${donation.medicalNotes}",
                          style: textTheme.labelSmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons for pending donations
          if (donation.canBeCompleted) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 52,
                  width: 140,
                  child: TextButton(
                    onPressed: () => _showCancelDialog(donation),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      "Cancelar",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  height: 52,
                  width: 140,
                  child: TextButton(
                    onPressed: () => _showCompleteDialog(donation),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      "Concluir",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}