import 'package:flutter/material.dart';

import '../../../../domain/entities/entities.dart';
import '../../../../domain/entities/repository_arguments.dart';
import '../../../deployment/common/modern/gradient_buttons.dart';
import '../../../deployment/common/modern/modern_text_field.dart';

class EnvironmentVarsList extends StatefulWidget {
  const EnvironmentVarsList({
    super.key,
    required this.environmentVars,
    required this.onEnvironmentVarsChanged,
    required this.repo,
  });

  final Repository repo;
  final List<EnvironmentVar> environmentVars;
  final ValueChanged<List<EnvironmentVar>> onEnvironmentVarsChanged;

  @override
  State<EnvironmentVarsList> createState() => _EnvironmentVarsListState();
}

class _EnvironmentVarsListState extends State<EnvironmentVarsList> {
  late List<EnvironmentVar> _environmentVars;

  @override
  void initState() {
    super.initState();
    _environmentVars = List.from(widget.environmentVars);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._environmentVars.asMap().entries.map((entry) {
          final index = entry.key;
          final envVar = entry.value;
          return _buildEnvironmentVarRow(envVar, index);
        }),
        const SizedBox(height: 16),
        GradientActionButton(
          icon: Icons.add_rounded,
          label: 'Agregar Variable',
          enabled: true,
          onPressed: () => _addEnvironmentVar(widget.repo.id),
          enabledGradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF03A9F4)],
          ),
          width: double.infinity,
          height: 40,
        ),
      ],
    );
  }

  Widget _buildEnvironmentVarRow(EnvironmentVar envVar, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: ModernTextField(
              initialValue: envVar.key,
              labelText: 'Clave',
              onChanged: (value) {
                _updateEnvironmentVar(
                  index,
                  envVar.copyWith(key: value),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ModernTextField(
              initialValue: envVar.value,
              labelText: 'Valor',
              hintText: 'Recomendamos pasar variables encriptadas',
              onChanged: (value) {
                _updateEnvironmentVar(
                  index,
                  envVar.copyWith(value: value),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            color: Colors.red,
            onPressed: () => _removeEnvironmentVar(index),
          ),
        ],
      ),
    );
  }

  void _addEnvironmentVar(int id) {
    setState(() {
      _environmentVars.add(
        EnvironmentVar(
          key: '',
          value: '',
          id: -1,
          repoId: id,
        ),
      );
    });
    _notifyParent();
  }

  void _removeEnvironmentVar(int index) {
    setState(() {
      _environmentVars.removeAt(index);
    });
    _notifyParent();
  }

  void _updateEnvironmentVar(int index, EnvironmentVar updatedVar) {
    setState(() {
      _environmentVars[index] = updatedVar;
    });
    _notifyParent();
  }

  void _notifyParent() {
    widget.onEnvironmentVarsChanged(_environmentVars);
  }
}
