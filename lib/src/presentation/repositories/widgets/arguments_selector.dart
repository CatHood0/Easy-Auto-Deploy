import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/repository_arguments.dart';

class RepositoryArgumentsSelector extends StatelessWidget {
  const RepositoryArgumentsSelector({
    super.key,
    required this.currentArgument,
    required this.onArgumentsChanged,
    required this.availableArguments,
  });

  final RepositoryArguments currentArgument;
  final List<RepositoryArguments> availableArguments;
  final ValueChanged<RepositoryArguments> onArgumentsChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton2(
      buttonStyleData: ButtonStyleData(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        offset: Offset(0, -5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      onChanged: (newArgs) {
        if (newArgs == null) return;
        onArgumentsChanged(newArgs);
      },
      items: <DropdownMenuItem<RepositoryArguments>>[
        ...availableArguments.map((RepositoryArguments arg) {
          return DropdownMenuItem(
            value: arg,
            child: Text(
              arg.identifier,
              style: TextStyle(
                fontFamily: 'JetBrains Mono NF',
                fontFamilyFallback: ['Monospace', 'Consolas'],
              ),
            ),
          );
        })
      ],
      isExpanded: true,
      hint: Text(
        'Seleccionar tipo de argumentos',
        style: TextStyle(
          fontFamily: 'JetBrains Mono NF',
          fontFamilyFallback: ['Monospace', 'Consolas'],
        ),
      ),
    );
  }
}
