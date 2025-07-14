import 'package:flutter/material.dart';
import 'package:vitalink/styles.dart';

class RichTextLabel extends StatelessWidget {
  final String label;
  const RichTextLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    var labelStyle = Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(fontSize: 18);
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(text: label, style: labelStyle),
        TextSpan(text: '*', style: labelStyle.copyWith(color: Styles.primary)),
      ],
    ));
  }
}
