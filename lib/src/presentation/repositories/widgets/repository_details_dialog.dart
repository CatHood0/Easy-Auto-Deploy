import 'package:auto_deployment/src/domain/entities/command/command_base.dart';
import 'package:auto_deployment/src/domain/entities/repository_arguments.dart';
import 'package:auto_deployment/src/domain/repository/repo_provider_repository.dart';
import 'package:auto_deployment/src/presentation/bloc/repository_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/entities.dart';
import '../../deployment/common/modern/gradient_buttons.dart';
import '../../deployment/common/modern/modern_text_field.dart';

class RepositoryEditDialog extends StatefulWidget {
  final VoidCallback? reload;
  final RepoProviderRepository provider;
  final bool isInsertion;
  final Repository? selection;
  const RepositoryEditDialog({
    super.key,
    required this.provider,
    required this.isInsertion,
    this.reload,
    this.selection,
  });

  @override
  State<RepositoryEditDialog> createState() => _RepositoryEditDialogState();
}

class _RepositoryEditDialogState extends State<RepositoryEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repoController = TextEditingController();
  final _branchController = TextEditingController(text: 'main');
  final _imageNameController = TextEditingController();
  bool _requireAuth = false;

  @override
  void initState() {
    _repoController.text = widget.selection?.repo ?? '';
    _branchController.text = widget.selection?.branch ?? '';
    _imageNameController.text = widget.selection?.repoImageName ?? '';
    _requireAuth = widget.selection?.requireAuth ?? false;
    super.initState();
  }

  @override
  void dispose() {
    _repoController.dispose();
    _branchController.dispose();
    _imageNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isInsertion ? 'Agregar Repositorio' : 'Editar Repositorio',
        style: TextStyle(
          fontFamily: 'JetBrains Mono NF',
          fontFamilyFallback: ['Monospace', 'Consolas'],
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernTextField(
                controller: _repoController,
                labelText: 'URL del Repositorio',
                hintText: 'https://github.com/usuario/repo.git',
                icon: const Icon(Icons.link_rounded),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'La URL es requerida';
                  }
                  if (!value!.startsWith('http')) {
                    return 'URL debe comenzar con http/https';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: _branchController,
                labelText: 'Rama',
                hintText: 'main',
                icon: const Icon(Icons.account_tree_rounded),
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: _imageNameController,
                labelText: 'Nombre de Imagen',
                hintText: 'mi-aplicacion',
                icon: const Icon(Icons.tag_rounded),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El nombre de imagen es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Requiere Autenticación',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono NF',
                        fontFamilyFallback: ['Monospace', 'Consolas'],
                      ),
                    ),
                  ),
                  Switch(
                    value: _requireAuth,
                    onChanged: (value) {
                      setState(() {
                        _requireAuth = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        GradientActionButton(
          icon: Icons.add_rounded,
          label: widget.isInsertion ? 'Agregar' : 'Actualizar',
          enabled: true,
          onPressed: _addRepository,
          enabledGradient: const LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF64DD17)],
          ),
          width: 120,
          height: 40,
        ),
      ],
    );
  }

  void _addRepository() async {
    if (_formKey.currentState?.validate() ?? false) {
      final Repository newRepo = Repository(
        id: -1,
        repo: _repoController.text,
        branch: _branchController.text,
        requireAuth: _requireAuth,
        repoImageName: _imageNameController.text,
        instructions: <RepositoryArguments>[
          RepositoryArguments(
            id: -1,
            repoId: -1,
            identifier: 'Basic Arguments',
            steps: <CommandBase>[],
            environmentVars: <EnvironmentVar>[],
          ),
        ],
        lastArgumentSelected: null,
        updatedAt: DateTime.now(),
      );

      if (!widget.isInsertion) {
        assert(
            widget.selection != null,
            'dialog was marked as '
            'no insertion, but '
            'found nullable repository instance');
        context.read<RepositoryBloc>().add(
              UpdateRepository(
                widget.selection!.copyWith(
                  repo: _repoController.text,
                  branch: _branchController.text,
                  requireAuth: _requireAuth,
                  repoImageName: _imageNameController.text,
                ),
                false,
              ),
            );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
        });
        return;
      }

      context.read<RepositoryBloc>().add(
            AddRepository(newRepo),
          );

      // Guardar el repositorio (depende de tu implementación)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }
  }
}
