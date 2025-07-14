import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:vitalink/services/stores/nearby_store.dart';

class LocationWarning extends StatelessWidget {
  final NearbyStore nearbyStore;
  final List<BloodCenterModel> bloodCenters;

  const LocationWarning({
    Key? key,
    required this.nearbyStore,
    required this.bloodCenters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.mapPin, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Localização desativada',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Para encontrar hemocentros próximos, ative a localização do seu dispositivo.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              // Tentar novamente
              await nearbyStore.syncNearbyBloodCenters(
                bloodCentersFromApi: bloodCenters,
              );
            },
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text('Tentar novamente'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}