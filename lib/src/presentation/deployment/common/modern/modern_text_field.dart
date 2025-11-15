import 'package:flutter/material.dart';

class ModernTextField extends StatelessWidget {
  const ModernTextField({
    super.key,
    this.controller,
    this.onFieldSubmitted,
    this.validator,
    this.icon,
    this.labelText,
    this.hintText,
    this.helperText,
    this.obscureText = false,
    this.maxLines,
    this.input,
    this.onChanged,
    this.suffixIcon,
    this.enabled = true,
    this.focusNode,
    this.initialValue,
  });

  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Icon? icon;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final TextInputType? input;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: hasFocus && enabled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        Theme.of(context).colorScheme.primary.withOpacity(0.02),
                      ],
                    )
                  : null,
              color: enabled
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasFocus && enabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: hasFocus ? 2 : 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (labelText != null) ...[
                    Text(
                      labelText!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'JetBrains Mono NF',
                        fontFamilyFallback: ['Monospace', 'Consolas'],
                        color: hasFocus && enabled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon!.icon,
                          size: 20,
                          color: hasFocus && enabled
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          initialValue: initialValue,
                          focusNode: focusNode,
                          obscureText: obscureText,
                          onFieldSubmitted: onFieldSubmitted,
                          validator: validator,
                          onChanged: onChanged,
                          maxLines: maxLines ?? 1,
                          enabled: enabled,
                          keyboardType: input ?? TextInputType.text,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'JetBrains Mono NF',
                            fontFamilyFallback: ['Monospace', 'Consolas'],
                            color: enabled
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                          ),
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontFamily: 'JetBrains Mono NF',
                              fontFamilyFallback: ['Monospace', 'Consolas'],
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (suffixIcon != null) ...[
                        const SizedBox(width: 8),
                        suffixIcon!,
                      ],
                    ],
                  ),
                  if (helperText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      helperText!,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'JetBrains Mono NF',
                        fontFamilyFallback: ['Monospace', 'Consolas'],
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
