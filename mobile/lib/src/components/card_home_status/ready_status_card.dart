import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReadyStatusCard extends StatelessWidget {
  const ReadyStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Colors.green; // Cor base para o status "pronto"

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
            LucideIcons.heartHandshake,
            color: cardColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Você já pode doar sangue e salvar vidas!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cardColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
