import 'package:auto_deployment/src/domain/entities/deployment_preferences.dart';
import 'package:auto_deployment/src/presentation/deployment/common/modern/modern_text_field.dart';
import 'package:auto_deployment/src/presentation/deployment/common/modern/modern_checkbox_switcher.dart';
import 'package:flutter/material.dart';

class DeploymentBuildOptions extends StatefulWidget {
  const DeploymentBuildOptions({
    super.key,
    required this.useFullBuild,
    required this.cloneFullProject,
  });

  final ValueNotifier<bool> useFullBuild;
  final ValueNotifier<bool> cloneFullProject;

  @override
  State<DeploymentBuildOptions> createState() => _DeploymentBuildOptionsState();
}

class _DeploymentBuildOptionsState extends State<DeploymentBuildOptions> {
  final TextEditingController _launchOptionsController = TextEditingController(
    text: DeploymentPreferences.getCachedDeploymentPreferences().launchOptions,
  );
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernTextField(
          controller: _launchOptionsController,
          maxLines: 1,
          input: TextInputType.text,
          onChanged: (value) {
            DeploymentPreferences.getCachedDeploymentPreferences()
                .copyWith(launchOptions: value)
                .saveToPref();
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ModernCheckboxSwitcher(
                valueListenable: widget.useFullBuild,
                title: 'Usar Full Build',
                alternativeText1: 'Reconstrucción completa activada',
                alternativeText2: 'Usar caché de construcción',
                icon: Icons.build_circle,
                onChanged: (newVal) {
                  if (newVal == null) return;
                  widget.useFullBuild.value = newVal;
                  DeploymentPreferences.getCachedDeploymentPreferences()
                      .copyWith(preferFullBuild: newVal)
                      .saveToPref();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernCheckboxSwitcher(
                valueListenable: widget.cloneFullProject,
                title: 'Clonar proyecto completo',
                icon: Icons.download_for_offline,
                alternativeText1: 'Descargando historial completo',
                alternativeText2:
                    'Buscaremos el proyecto sin necesidad de clonar',
                onChanged: (newVal) {
                  if (newVal == null) return;
                  widget.cloneFullProject.value = newVal;
                  DeploymentPreferences.getCachedDeploymentPreferences()
                      .copyWith(cloneFullProyectAlways: newVal)
                      .saveToPref();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
