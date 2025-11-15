import 'package:flutter/material.dart';

import '../../../domain/entities/deployment_preferences.dart';
import '../../widgets/button_switcher.dart';

class BuildSettingsSection extends StatelessWidget {
  const BuildSettingsSection({
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
            ButtonSwitcher(
              title: 'Full Build',
              subtitle: 'Forzar reconstrucción completa sin cache',
              value: preferences.preferFullBuild,
            ),
            const SizedBox(height: 16),
            ButtonSwitcher(
              title: 'Clonado Completo',
              subtitle: 'Descargar historial completo del repositorio',
              value: preferences.cloneFullProyectAlways,
            ),
          ],
        ),
      ),
    );
  }
}
