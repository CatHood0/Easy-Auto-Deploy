import 'package:auto_deployment/src/domain/entities/command/create_file_command.dart';
import 'package:auto_deployment/src/domain/entities/command/move_file_command.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/command/command_base.dart';
import '../../../../domain/entities/command/rename_file_command.dart';
import '../../../../domain/entities/command/update_file_content_command.dart';
import '../../../deployment/common/modern/gradient_buttons.dart';
import '../command_widget.dart';

class CommandsList extends StatefulWidget {
  const CommandsList({
    super.key,
    required this.commands,
    required this.onCommandsChanged,
  });

  final List<CommandBase> commands;
  final ValueChanged<List<CommandBase>> onCommandsChanged;

  @override
  State<CommandsList> createState() => _CommandsListState();
}

class _CommandsListState extends State<CommandsList> {
  late List<CommandBase> _commands;

  @override
  void initState() {
    super.initState();
    _commands = List.from(widget.commands);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _commands.length,
          itemBuilder: (context, index) {
            final command = _commands[index];
            return CommandWidget(
              key: ValueKey('command-$index-${command.hashCode}'),
              command: command,
              index: index,
              onCommandChanged: (updatedCommand) {
                _updateCommand(index, updatedCommand);
              },
              onCommandDeleted: () {
                _removeCommand(index);
              },
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final command = _commands.removeAt(oldIndex);
              _commands.insert(newIndex, command);
            });
            _notifyParent();
          },
        ),
        const SizedBox(height: 16),
        _buildAddCommandButton(),
      ],
    );
  }

  Widget _buildAddCommandButton() {
    return PopupMenuButton<Type>(
      child: GradientActionButton(
        icon: Icons.add_rounded,
        label: 'Agregar Comando',
        enabled: true,
        onPressed: () {}, // El popup se abre automáticamente
        enabledGradient: const LinearGradient(
          colors: [
            Color(0xFF2196F3),
            Color(0xFF03A9F4),
          ],
        ),
        width: double.infinity,
        height: 40,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<Type>(
          value: CreateFileCommand,
          child: Text('Crear Archivo'),
        ),
        const PopupMenuItem<Type>(
          value: MoveFileCommand,
          child: Text('Mover Archivo'),
        ),
        const PopupMenuItem<Type>(
          value: RenameFileCommand,
          child: Text('Renombrar Archivo'),
        ),
        const PopupMenuItem<Type>(
          value: UpdateFileContentCommand,
          child: Text('Actualizar Contenido'),
        ),
      ],
      onSelected: (commandType) {
        _addCommand(commandType);
      },
    );
  }

  void _addCommand(Type commandType) {
    CommandBase newCommand;
    switch (commandType) {
      case const (CreateFileCommand):
        newCommand = CreateFileCommand(
          filePath: '',
          content: '',
        );
        break;
      case const (MoveFileCommand):
        newCommand = MoveFileCommand(
          from: '',
          to: '',
        );
        break;
      case const (RenameFileCommand):
        newCommand = RenameFileCommand(
          oldPath: '',
          newPath: '',
        );
        break;
      case const (UpdateFileContentCommand):
        newCommand = UpdateFileContentCommand(
          filePath: '',
          matchExpression: '',
          valueReplacement: '',
        );
        break;
      default:
        throw Exception('Unknown command type $commandType');
    }

    setState(() {
      _commands.add(newCommand);
    });
    _notifyParent();
  }

  void _removeCommand(int index) {
    setState(() {
      _commands.removeAt(index);
    });
    _notifyParent();
  }

  void _updateCommand(int index, CommandBase updatedCommand) {
    setState(() {
      _commands[index] = updatedCommand;
    });
    _notifyParent();
  }

  void _notifyParent() {
    widget.onCommandsChanged(_commands);
  }
}
