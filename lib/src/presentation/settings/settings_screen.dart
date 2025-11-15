import 'package:auto_deployment/src/presentation/settings/common/settings_build_section.dart';
import 'package:auto_deployment/src/presentation/settings/common/settings_header.dart';
import 'package:auto_deployment/src/presentation/settings/widgets/installation_setting_section.dart';
import 'package:auto_deployment/src/presentation/settings/widgets/launch_options_setting_section.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/deployment_preferences.dart';
import '../deployment/common/modern/gradient_buttons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: const SettingsContent(),
    );
  }
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = DeploymentPreferences.getCachedDeploymentPreferences();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const SectionHeader(title: 'Preferencias de Build'),
          BuildSettingsSection(preferences: preferences),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Configuración de Instalación'),
          InstallationSettingsSection(preferences: preferences),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Opciones de Lanzamiento'),
          LaunchSettingsSection(preferences: preferences),
          const SizedBox(height: 32),
          const SaveSettingsButton(),
        ],
      ),
    );
  }
}

class SaveSettingsButton extends StatelessWidget {
  const SaveSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientActionButton(
      icon: Icons.save_rounded,
      label: 'Guardar Configuración',
      enabled: true,
      onPressed: () {
        // Guardar preferencias
      },
      enabledGradient: const LinearGradient(
        colors: [Color(0xFF00C853), Color(0xFF64DD17)],
      ),
      width: double.infinity,
    );
  }
}
