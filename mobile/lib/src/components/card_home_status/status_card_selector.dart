import 'package:flutter/material.dart';
import 'package:vitalink/services/stores/donation_store.dart';
import 'package:vitalink/src/components/card_home_status/null_donate_status_card.dart';
import 'package:vitalink/src/components/card_home_status/pending_status_card.dart';
import 'package:vitalink/src/components/card_home_status/ready_status_card.dart';

class DonationStatusCardSelector extends StatelessWidget {
  final DonationStore donationStore;

  const DonationStatusCardSelector({
    Key? key,
    required this.donationStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Observa ambos os ValueNotifiers ao mesmo tempo
    return AnimatedBuilder(
      animation: Listenable.merge([
        donationStore.nextDonation,
        donationStore.donations,
      ]),
      builder: (context, child) {
        final nextDonation = donationStore.nextDonation.value;
        final donations = donationStore.donations.value;

        // Se não há próxima doação agendada
        if (nextDonation == null) {
          // Verificar histórico de doações
          // Se tem histórico de doações, verificar se pode doar novamente
          if (donations.isNotEmpty) {
            // Encontrar a última doação concluída
            final lastCompletedDonation = donations
                .where((d) => d.status == 'completed')
                .toList()
              ..sort((a, b) => b.donationDate.compareTo(a.donationDate));

            if (lastCompletedDonation.isNotEmpty) {
              // Calcular se já pode doar novamente (3 meses para homens, 4 para mulheres)
              final lastDonation = lastCompletedDonation.first;
              final waitPeriod =
                  lastDonation.donorGender == 'M' ? 90 : 120; // dias
              final nextPossibleDate =
                  lastDonation.donationDate.add(Duration(days: waitPeriod));

              if (DateTime.now().isAfter(nextPossibleDate)) {
                // Já pode doar novamente
                return const ReadyStatusCard();
              } else {
                // Ainda em período de espera
                return PendingStatusCard(
                  nextPossibleDate: nextPossibleDate,
                );
              }
            }
          }

          // Verificar se há doações agendadas (scheduled)
          final scheduledDonations = donations
              .where((d) => d.status == 'scheduled' || d.status == 'confirmed')
              .toList();

          if (scheduledDonations.isNotEmpty) {
            // Ordenar por data (mais próxima primeiro)
            scheduledDonations
                .sort((a, b) => a.donationDate.compareTo(b.donationDate));
            // Mostrar card de doação pendente com a próxima doação
            return PendingStatusCard(
              donation: scheduledDonations.first,
            );
          }

          // Sem histórico de doações ou todas foram canceladas
          return const DidNotDonateStatusCard();
        } else {
          // Tem uma doação agendada
          if (nextDonation.status == 'scheduled' ||
              nextDonation.status == 'confirmed') {
            // Mostrar card de doação pendente
            return PendingStatusCard(
              donation: nextDonation,
            );
          } else if (nextDonation.status == 'completed') {
            // Doação concluída recentemente
            // Calcular se já pode doar novamente
            final waitPeriod =
                nextDonation.donorGender == 'M' ? 90 : 120; // dias
            final nextPossibleDate =
                nextDonation.donationDate.add(Duration(days: waitPeriod));

            if (DateTime.now().isAfter(nextPossibleDate)) {
              // Já pode doar novamente
              return const ReadyStatusCard();
            } else {
              // Ainda em período de espera
              return PendingStatusCard(
                nextPossibleDate: nextPossibleDate,
              );
            }
          } else {
            // Outros status (cancelado, etc)
            return const DidNotDonateStatusCard();
          }
        }
      },
    );
  }
}
