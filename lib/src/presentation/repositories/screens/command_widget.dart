import 'package:flutter/material.dart';

import '../../../domain/entities/command/command_base.dart';
import '../../../domain/entities/command/create_file_command.dart';
import '../../../domain/entities/command/move_file_command.dart';
import '../../../domain/entities/command/rename_file_command.dart';
import '../../../domain/entities/command/update_file_content_command.dart';
import '../../deployment/common/modern/modern_text_field.dart';

class CommandWidget extends StatefulWidget {
  const CommandWidget({
    super.key,
    required this.command,
    required this.index,
    required this.onCommandChanged,
    required this.onCommandDeleted,
  });

  final CommandBase command;
  final int index;
  final ValueChanged<CommandBase> onCommandChanged;
  final VoidCallback onCommandDeleted;

  @override
  State<CommandWidget> createState() => _CommandWidgetState();
}

class _CommandWidgetState extends State<CommandWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ExpansionTile(
        key: ValueKey('command-expandable-${widget.index}'),
        initiallyExpanded: _isExpanded,
        leading: ReorderableDragStartListener(
          index: widget.index,
          child: const Icon(Icons.drag_handle_rounded),
        ),
        title: Row(
          children: [
            Text(
              '${widget.index + 1}.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'JetBrains Mono NF',
                fontFamilyFallback: ['Monospace', 'Consolas'],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getCommandTitle(widget.command),
              style: TextStyle(
                fontFamily: 'JetBrains Mono NF',
                fontFamilyFallback: ['Monospace', 'Consolas'],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_rounded),
          color: Colors.red,
          onPressed: widget.onCommandDeleted,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCommandContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandContent() {
    return widget.command.map(
      createFile: (cmd) => CreateFileCommandWidget(
        command: cmd,
        onChanged: widget.onCommandChanged,
      ),
      moveFile: (cmd) => MoveFileCommandWidget(
        command: cmd,
        onChanged: widget.onCommandChanged,
      ),
      renameFile: (cmd) => RenameFileCommandWidget(
        command: cmd,
        onChanged: widget.onCommandChanged,
      ),
      updateFileContent: (cmd) => UpdateFileContentCommandWidget(
        command: cmd,
        onChanged: widget.onCommandChanged,
      ),
    );
  }

  String _getCommandTitle(CommandBase command) {
    return command.map(
      createFile: (cmd) => 'Crear Archivo',
      moveFile: (cmd) => 'Mover Archivo',
      renameFile: (cmd) => 'Renombrar Archivo',
      updateFileContent: (cmd) => 'Actualizar Contenido',
    );
  }
}

class RenameFileCommandWidget extends StatelessWidget {
  const RenameFileCommandWidget({
    super.key,
    required this.command,
    required this.onChanged,
  });

  final RenameFileCommand command;
  final ValueChanged<CommandBase> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Renombra un archivo o directorio en el proyecto clonado',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'JetBrains Mono NF',
            fontFamilyFallback: ['Monospace', 'Consolas'],
          ),
        ),
        const SizedBox(height: 16),
        ModernTextField(
          initialValue: command.oldPath,
          labelText: 'Ruta completa al archivo',
          onChanged: (value) {
            onChanged(command.copyWith(oldPath: value));
          },
        ),
        const SizedBox(height: 16),
        ModernTextField(
          initialValue: command.newPath,
          labelText: 'Nuevo nombre',
          onChanged: (value) {
            onChanged(command.copyWith(newPath: value));
          },
        ),
      ],
    );
  }
}

class CreateFileCommandWidget extends StatelessWidget {
  const CreateFileCommandWidget({
    super.key,
    required this.command,
    required this.onChanged,
  });

  final CreateFileCommand command;
  final ValueChanged<CommandBase> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crea un nuevo archivo en el proyecto clonado con el contenido especificado',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'JetBrains Mono NF',
            fontFamilyFallback: ['Monospace', 'Consolas'],
          ),
        ),
        const SizedBox(height: 16),
        ModernTextField(
          initialValue: command.filePath,
          labelText: 'Ruta del archivo',
          hintText: 'ej: /src/config/app.js',
          onChanged: (value) {
            onChanged(command.copyWith(filePath: value));
          },
          validator: (value) {
            if (value?.isEmpty ?? true) return 'La ruta es requerida';
            return null;
          },
        ),
        const SizedBox(height: 16),
        ModernTextField(
          initialValue: command.content,
          labelText: 'Contenido del archivo',
          hintText: 'Contenido que tendrá el nuevo archivo',
          maxLines: 5,
          onChanged: (value) {
            onChanged(command.copyWith(content: value));
          },
        ),
      ],
    );
  }
}

class MoveFileCommandWidget extends StatelessWidget {
  const MoveFileCommandWidget({
    super.key,
    required this.command,
    required this.onChanged,
  });

  final MoveFileCommand command;
  final ValueChanged<CommandBase> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mueve un archivo o directorio a una nueva ubicación en el proyecto',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'JetBrains Mono NF',
            fontFamilyFallback: ['Monospace', 'Consolas'],
          ),
        ),
        const SizedBox(height: 16),
        ModernTextField(
          initialValue: command.from,
          labelText: 'Ruta origen',
          hintText: 'ej: /src/old-location/file.js',
          onChanged: (value) {
            onChanged(command.copyWith(from: value));
          },
          validator: (value) {
            if (value?.isEmpty ?? true) return 'La ruta origen es requerida';
            return null;
          },
        ),
        const SizedBox(height: 16),
        ModernTextField(
          initialValue: command.to,
          labelText: 'Ruta destino',
          hintText: 'ej: /src/new-location/file.js',
          onChanged: (value) {
            onChanged(command.copyWith(to: value));
          },
          validator: (value) {
            if (value?.isEmpty ?? true) return 'La ruta destino es requerida';
            return null;
          },
        ),
      ],
    );
  }
}

class UpdateFileContentCommandWidget extends StatelessWidget {
  const UpdateFileContentCommandWidget({
    super.key,
    required this.command,
    required this.onChanged,
  });

  final UpdateFileContentCommand command;
  final ValueChanged<CommandBase> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actualiza el contenido de un archivo existente en el proyecto',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'JetBrains Mono NF',
            fontFamilyFallback: ['Monospace', 'Consolas'],
          ),
        ),
        const SizedBox(height: 16),
        ModernTextField(
          initialValue: command.filePath,
          labelText: 'Ruta del archivo',
          hintText: 'ej: /src/config/database.js',
          onChanged: (value) {
            onChanged(command.copyWith(filePath: value));
          },
          validator: (value) {
            if (value?.isEmpty ?? true) return 'La ruta es requerida';
            return null;
          },
        ),
        const SizedBox(height: 16),
        ModernTextField(
          initialValue: command.matchExpression,
          labelText: 'Expresion Regular',
          hintText: 'Matchea con el contenido que deseas reemplazar',
          maxLines: 3,
          onChanged: (String value) {
            onChanged(command.copyWith(
              matchExpression: value,
            ));
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Si deseas referenciar a una variable de '
          'entorno, encierra el nombre entre {}'
          '\nEjemplo: \${{DB_PASS}} o \$[[DB_PASS]]',
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey.shade600,
            fontFamily: 'JetBrains Mono NF',
            fontFamilyFallback: <String>['Monospace', 'Consolas'],
          ),
        ),
        const SizedBox(height: 4),
        ModernTextField(
          initialValue: command.valueReplacement,
          labelText: 'Contenido de reemplazo',
          hintText: 'Contenido que reemplazará al anterior',
          maxLines: 5,
          onChanged: (value) {
            onChanged(command.copyWith(
              valueReplacement: value,
            ));
          },
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'El nuevo contenido es requerido';
            }
            return null;
          },
        ),
      ],
    );
  }
}
