import 'package:flutter/material.dart';

class ButtonSwitcher extends StatelessWidget {
  const ButtonSwitcher({
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
