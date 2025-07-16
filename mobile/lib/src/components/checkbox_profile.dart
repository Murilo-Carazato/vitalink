import 'package:flutter/material.dart';
import 'package:vitalink/styles.dart';

class CheckBoxProfile extends StatefulWidget {
  final String label;
  final bool option;
  final void Function(bool?)? onChanged;
  const CheckBoxProfile({super.key, required this.option, required this.label, required this.onChanged});

  @override
  State<CheckBoxProfile> createState() => _CheckBoxProfileState();
}

class _CheckBoxProfileState extends State<CheckBoxProfile> {
  @override
  Widget build(BuildContext context) {
    // Agora podemos usar diretamente o estilo do tema, sem verificações de nulo
    var labelStyle = Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(fontSize: 18);
        
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Checkbox.adaptive(value: widget.option, onChanged: widget.onChanged),
        RichText(
          text: TextSpan(children: [
            TextSpan(text: widget.label, style: labelStyle),
            TextSpan(text: '*', style: labelStyle.copyWith(color: Styles.primary)),
          ]),
        ),
      ],
    );
  }
}
