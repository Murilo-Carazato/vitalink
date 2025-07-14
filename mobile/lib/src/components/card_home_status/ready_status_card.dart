import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/styles.dart';

class ReadyStatusCard extends StatelessWidget {
  const ReadyStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Styles.green,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.heartHandshake,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Flexible(child: Text('Você já pode doar sangue e salvar vidas!', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white), softWrap: true))
            ],
          ),
        ));
  }
}
