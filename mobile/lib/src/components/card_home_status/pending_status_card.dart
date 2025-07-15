import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/services/models/donation_model.dart';

class PendingStatusCard extends StatelessWidget {
  final DonationModel? donation;
  final DateTime? nextPossibleDate;

  const PendingStatusCard({
    Key? key,
    this.donation,
    this.nextPossibleDate,
  }) : super(key: key);

  String _getRemainingTimeText() {
    if (donation != null) {
      // Mostrar tempo até a próxima doação agendada
      final daysRemaining =
          donation!.donationDate.difference(DateTime.now()).inDays;
      if (daysRemaining > 0) {
        return '$daysRemaining dias';
      } else {
        return 'Hoje!';
      }
    } else if (nextPossibleDate != null) {
      // Mostrar tempo até poder doar novamente
      final daysRemaining = nextPossibleDate!.difference(DateTime.now()).inDays;
      final months = daysRemaining ~/ 30;
      final days = daysRemaining % 30;

      if (months > 0) {
        return '$months meses e $days dias';
      } else {
        return '$days dias';
      }
    }

    return 'Em breve';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Colors.orange; // Cor base para o status "pendente"

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.hourglass,
            color: cardColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  donation != null
                      ? 'Próxima doação agendada para:'
                      : 'Você poderá doar novamente em:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _getRemainingTimeText(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
