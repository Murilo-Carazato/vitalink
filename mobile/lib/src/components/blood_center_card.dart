import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/services/helpers/blood_center_name.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BloodCenterCard extends StatelessWidget {
  final double sizeOfCard;
  final BloodCenterModel bloodCenter;
  const BloodCenterCard({super.key, required this.sizeOfCard, required this.bloodCenter});

  @override
  Widget build(BuildContext context) {
    var name = BloodCenterName(bloodCenter.name);
    return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Theme.of(context).dividerTheme.color!)),
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: InkWell(
          onTap: () {},
          child: SizedBox(
            height: 250,
            width: sizeOfCard,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            child: Text(
                          name.formatName().first,
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 18),
                          softWrap: true,
                          maxLines: 1,
                        )),
                        Flexible(
                            child: Text(
                          name.formatName().last,
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        )),
                        const Divider(),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(LucideIcons.mapPin, color: Theme.of(context).textTheme.labelSmall!.color),
                            ),
                            Flexible(
                                child: Text(
                              bloodCenter.address,
                              style: Theme.of(context).textTheme.labelSmall!,
                              softWrap: true,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        )
                      ],
                    ),
                  ),
                  if (bloodCenter.phoneNumber != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        await launchUrlString("tel:${bloodCenter.phoneNumber!}");
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.phoneCall),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                //Formata número de telefone no padrão brasileiro
                                UtilBrasilFields.obterTelefone(bloodCenter.phoneNumber!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ));
  }
}
