import 'package:flutter/material.dart';
import 'package:vitalink/styles.dart';

class ButtonHomePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final void Function()? onTap;
  final double sizeOfCard;
  const ButtonHomePage({super.key, required this.icon, required this.title, this.onTap, required this.sizeOfCard});

  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Theme.of(context).dividerTheme.color!)),
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 79,
            width: sizeOfCard,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: Styles.primary,
                  ),
                  const SizedBox(width: 10),
                  Flexible(child: Text(title, style: Theme.of(context).textTheme.headlineSmall, softWrap: true))
                ],
              ),
            ),
          ),
        ));
  }
}
