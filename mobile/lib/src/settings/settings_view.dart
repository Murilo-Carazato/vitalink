import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/styles.dart';
import 'settings_controller.dart';

/// Exibe as várias configurações que podem ser personalizadas pelo usuário.
///
/// Quando um usuário altera uma configuração, o SettingsController é atualizado e
/// os Widgets que escutam o SettingsController são reconstruídos.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Aparência',
            children: [
              _buildThemeSelector(context),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Sobre o aplicativo',
            children: [
              _buildInfoTile(
                context,
                title: 'Versão',
                subtitle: '1.0.0',
                icon: LucideIcons.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            context,
            title: 'Tema do sistema',
            icon: LucideIcons.monitor,
            value: ThemeMode.system,
          ),
          const Divider(height: 1),
          _buildThemeOption(
            context,
            title: 'Tema claro',
            icon: LucideIcons.sun,
            value: ThemeMode.light,
          ),
          const Divider(height: 1),
          _buildThemeOption(
            context,
            title: 'Tema escuro',
            icon: LucideIcons.moon,
            value: ThemeMode.dark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required ThemeMode value,
  }) {
    final isSelected = controller.themeMode == value;
    
    return InkWell(
      onTap: () => controller.updateThemeMode(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Styles.primary : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Styles.primary : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                LucideIcons.check,
                color: Styles.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
