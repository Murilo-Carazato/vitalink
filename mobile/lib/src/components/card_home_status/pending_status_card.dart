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
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: const Color(0xFFFFF500),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: 58,
            child: LayoutBuilder(
              builder: (context, constraints) => Flex(
                mainAxisSize: MainAxisSize.max,
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * (10 / 100),
                    child: const Icon(
                      LucideIcons.alarmMinus,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: constraints.maxWidth * (2 / 100)),
                  SizedBox(
                    width: constraints.maxWidth * (88 / 100),
                    child: Flex(
                      direction: Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          donation != null
                              ? 'Próxima doação agendada para:'
                              : 'Pode doar sangue novamente em:',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis),
                          maxLines: 1,
                        ),
                        Text(_getRemainingTimeText(),
                            style: Theme.of(context).textTheme.bodyMedium!,
                            softWrap: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
