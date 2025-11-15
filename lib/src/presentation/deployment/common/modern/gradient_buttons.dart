import 'package:flutter/material.dart';

class GradientActionButton extends StatelessWidget {
  const GradientActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.width = 130,
    this.height = 56,
    this.iconSize = 20,
    this.fontSize = 11,
    this.enabledGradient,
    this.disabledGradient,
    this.useColorsForShadow = true,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double iconSize;
  final double fontSize;
  final bool useColorsForShadow;
  final Gradient? enabledGradient;
  final Gradient? disabledGradient;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabledGradient = enabledGradient ??
        const LinearGradient(
          colors: [
            Color(0xFF757575),
            Color(0xFF9E9E9E),
          ],
        );

    final effectiveDisabledGradient = disabledGradient ??
        LinearGradient(
          colors: [
            Colors.grey.shade400,
            Colors.grey.shade500,
          ],
        );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient:
            enabled ? effectiveEnabledGradient : effectiveDisabledGradient,
        borderRadius: BorderRadius.circular(
          10,
        ),
        boxShadow: enabled && useColorsForShadow
            ? [
                BoxShadow(
                  color: effectiveEnabledGradient.colors.first.withOpacity(
                    0.3,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'JetBrains Mono NF',
                      fontFamilyFallback: ['Monospace', 'Consolas'],
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
