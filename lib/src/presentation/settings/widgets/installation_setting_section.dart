import 'package:flutter/material.dart';

import '../../../domain/entities/deployment_preferences.dart';
import '../../deployment/common/modern/modern_text_field.dart';

class InstallationSettingsSection extends StatelessWidget {
  const InstallationSettingsSection({
    super.key,
    required this.preferences,
  });

  final DeploymentPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InstallationSettingInput(
              title: 'Carpeta de Instalación',
              subtitle: 'Ruta donde se instalan los repositorios',
              value: preferences.preferredFolderInstallation,
            ),
            const SizedBox(height: 16),
            InstallationSettingInput(
              title: 'Última Ruta de Proyecto',
              subtitle: 'Ruta del último proyecto desplegado',
              value: preferences.lastProjectPath,
            ),
          ],
        ),
      ),
    );
  }
}

class InstallationSettingInput extends StatefulWidget {
  const InstallationSettingInput({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String title;
  final String subtitle;
  final String value;

  @override
  State<InstallationSettingInput> createState() =>
      _InstallationSettingInputState();
}

class _InstallationSettingInputState extends State<InstallationSettingInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'JetBrains Mono NF',
            fontFamilyFallback: ['Monospace', 'Consolas'],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'JetBrains Mono NF',
            fontFamilyFallback: ['Monospace', 'Consolas'],
          ),
        ),
        const SizedBox(height: 8),
        ModernTextField(
          controller: _controller,
          labelText: widget.title,
          onChanged: (value) {
            // Actualizar preferencias cuando cambie
          },
        ),
      ],
    );
  }
}
