import 'package:flutter/material.dart';

import '../../../domain/entities/deployment_preferences.dart';
import '../../deployment/common/modern/modern_text_field.dart';

class LaunchSettingsSection extends StatelessWidget {
  const LaunchSettingsSection({
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
            LaunchSettingInput(
              title: 'Opciones de Lanzamiento',
              subtitle: 'Parámetros adicionales para docker compose',
              value: preferences.launchOptions,
            ),
            const SizedBox(height: 16),
            LaunchSettingInput(
              title: 'Última Imagen Build',
              subtitle: 'Nombre de la última imagen construida',
              value: preferences.lastBuildedImage,
            ),
          ],
        ),
      ),
    );
  }
}

class LaunchSettingInput extends StatefulWidget {
  const LaunchSettingInput({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String title;
  final String subtitle;
  final String value;

  @override
  State<LaunchSettingInput> createState() => _LaunchSettingInputState();
}

class _LaunchSettingInputState extends State<LaunchSettingInput> {
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

class AdvancedSettingsSection extends StatelessWidget {
  const AdvancedSettingsSection({
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
            AdvancedSettingSwitch(
              title: 'Reinicio Automático',
              subtitle: 'Reiniciar automáticamente si falla el despliegue',
              value:
                  false, // Agregar esta propiedad a DeploymentPreferences si es necesario
            ),
            const SizedBox(height: 16),
            AdvancedSettingSwitch(
              title: 'Logs Detallados',
              subtitle: 'Mostrar logs detallados durante el despliegue',
              value:
                  true, // Agregar esta propiedad a DeploymentPreferences si es necesario
            ),
            const SizedBox(height: 16),
            AdvancedSettingInput(
              title: 'Tiempo de Espera',
              subtitle: 'Tiempo máximo de espera para operaciones (segundos)',
              value: '300',
            ),
          ],
        ),
      ),
    );
  }
}

class AdvancedSettingSwitch extends StatelessWidget {
  const AdvancedSettingSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String title;
  final String subtitle;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'JetBrains Mono NF',
                  fontFamilyFallback: ['Monospace', 'Consolas'],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: 'JetBrains Mono NF',
                  fontFamilyFallback: ['Monospace', 'Consolas'],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {
            // Actualizar preferencias
          },
        ),
      ],
    );
  }
}

class AdvancedSettingInput extends StatefulWidget {
  const AdvancedSettingInput({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String title;
  final String subtitle;
  final String value;

  @override
  State<AdvancedSettingInput> createState() => _AdvancedSettingInputState();
}

class _AdvancedSettingInputState extends State<AdvancedSettingInput> {
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
          input: TextInputType.number,
          onChanged: (value) {
            // Actualizar preferencias cuando cambie
          },
        ),
      ],
    );
  }
}
