import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/services/helpers/my_dates_formatter.dart';
import 'package:vitalink/services/helpers/user_name_initial.dart';
import 'package:vitalink/services/models/user_model.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:vitalink/styles.dart';

class UserHeader extends StatelessWidget {
  final UserStore user;
  const UserHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    // OUVE o ValueNotifier e reconstrói quando mudar
    return ValueListenableBuilder<List<UserModel>>(
      valueListenable: user.state,
      builder: (context, users, _) {
        final localUser = users.first;
        final userAge = MyDates(birthDate: localUser.birthDate);
        final userInitial = UserNameInitial(localUser.name).captureInitials;

        return Flex(
          direction: Axis.horizontal,
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              backgroundColor:
                  Theme.of(context).appBarTheme.backgroundColor!.withRed(75),
              radius: 30,
              child: Text(userInitial),
            ),
            const SizedBox(width: 17),
            SizedBox(
              width: (MediaQuery.sizeOf(context).width * 0.5992) - 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localUser.name, style: textTheme.bodyMedium),
                  Text('${userAge.calcularIdade} anos',
                      style: textTheme.bodySmall),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.droplet, color: Styles.primary),
                Text(localUser.bloodType ?? '', style: textTheme.bodyMedium),
              ],
            ),
          ],
        );
      },
    );
  }
}