import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/styles.dart';

class DidNotDonateStatusCard extends StatelessWidget {
  const DidNotDonateStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Styles.gray1,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.heartCrack,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Flexible(child: Text('Parece que você ainda não doou sangue. Doe para salvar vidas!', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white), softWrap: true))
            ],
          ),
        ));
  }
}
