import 'package:flutter/material.dart';
import 'package:vitalink/src/settings/settings_view.dart';

class ButtonSettings extends StatelessWidget {
  const ButtonSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: () => Navigator.restorablePushNamed(context, SettingsView.routeName), icon: const Icon(Icons.settings));
  }
}