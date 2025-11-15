import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ModernCheckboxSwitcher extends StatelessWidget {
  const ModernCheckboxSwitcher({
    super.key,
    required this.valueListenable,
    required this.title,
    required this.icon,
    required this.onChanged,
    required this.alternativeText1,
    required this.alternativeText2,
  });

  final ValueListenable<bool> valueListenable;
  final String title;
  final IconData icon;
  final ValueChanged<bool?> onChanged;
  final String alternativeText1;
  final String alternativeText2;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: valueListenable,
      builder: (
        context,
        value,
        child,
      ) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: value
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                16,
              ),
              onTap: () => onChanged(!value),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: value
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: value
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),
                        Switch.adaptive(
                          value: value,
                          onChanged: onChanged,
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'JetBrains Mono NF',
                        fontFamilyFallback: ['Monospace', 'Consolas'],
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value ? alternativeText1 : alternativeText2,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontFamily: 'JetBrains Mono NF',
                        fontFamilyFallback: ['Monospace', 'Consolas'],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
