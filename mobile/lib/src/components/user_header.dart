import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vitalink/services/helpers/my_dates_formatter.dart';
import 'package:vitalink/services/helpers/user_name_initial.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:vitalink/styles.dart';
import 'dart:io';

class UserHeader extends StatelessWidget {
  final UserStore user;
  const UserHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: user.state,
      builder: (context, child) {
        if (user.isLoading.value || user.state.value.isEmpty) {
          return const Skeletonizer(
            enabled: true,
            child: ListTile(
              leading: CircleAvatar(radius: 25),
              title: Text('Carregando...'),
              subtitle: Text('...'),
            ),
          );
        }

        var instantiatedUser = user.state.value.first;
        final photoPath = instantiatedUser.profilePhotoPath;

        return Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage:
                  photoPath != null ? FileImage(File(photoPath)) : null,
              child: photoPath == null
                  ? Text(UserNameInitial(instantiatedUser.name).captureInitials,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instantiatedUser.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 22),
                ),
                Text(
                  '${MyDates(birthDate: instantiatedUser.birthDate!).calcularIdade} anos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Spacer(), // Empurra o conteúdo para a direita
            Row(
              children: [
                const Icon(LucideIcons.droplet, color: Styles.primary),
                Text(instantiatedUser.bloodType ?? '',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        );
      },
    );
  }
}
