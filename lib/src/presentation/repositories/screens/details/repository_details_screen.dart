import 'package:auto_deployment/src/domain/entities/entities.dart';
import 'package:auto_deployment/src/domain/entities/repository_arguments.dart';
import 'package:auto_deployment/src/presentation/bloc/repository_bloc.dart';
import 'package:auto_deployment/src/presentation/deployment/common/modern/gradient_buttons.dart';
import 'package:auto_deployment/src/presentation/deployment/common/modern/modern_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'command_list_section.dart';
import 'environment_list_section.dart';

class RepositoryDetailsScreen extends StatefulWidget {
  const RepositoryDetailsScreen({
    super.key,
    required this.repository,
  });

  final Repository repository;

  @override
  State<RepositoryDetailsScreen> createState() =>
      _RepositoryDetailsScreenState();
}

class _RepositoryDetailsScreenState extends State<RepositoryDetailsScreen> {
  final TextEditingController _repoController = TextEditingController();
  final TextEditingController _repoBranchController = TextEditingController();
  final TextEditingController _repoImageController = TextEditingController();
  late Repository _currentRepository;
  late RepositoryArguments _repositoryArguments;
  int argIndex = -1;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentRepository = widget.repository;
    _repoController.text = _currentRepository.repo;
    _repoBranchController.text = _currentRepository.branch;
    _repoImageController.text = _currentRepository.repoImageName;
    final index = _currentRepository.instructions.indexWhere(
      (RepositoryArguments p) => p.repoId == _currentRepository.id,
    );
    // should not be never -1
    // we prefer stay safe from issues related with ranges
    if (index != -1) {
      argIndex = index;
      _repositoryArguments = _currentRepository.instructions.elementAt(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          flightShuttleBuilder: (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            return Material(
              color: Colors.transparent,
              child: Text(
                _currentRepository.repoImageName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'JetBrains Mono NF',
                  fontFamilyFallback: ['Monospace', 'Consolas'],
                ),
              ),
            );
          },
          tag: 'repository-${_currentRepository.id}',
          child: Text(
            _currentRepository.repoImageName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'JetBrains Mono NF',
              fontFamilyFallback: ['Monospace', 'Consolas'],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRepositoryDetailsSection(),
                    const SizedBox(height: 24),
                    _buildArgumentsSection(),
                    const SizedBox(height: 24),
                    _buildEnvironmentVarsSection(),
                    const SizedBox(height: 24),
                    _buildCommandsSection(),
                    const SizedBox(
                        height: 100), // Espacio para el botón flotante
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildUpdateButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildRepositoryDetailsSection() {
    return _buildSection(
      title: 'Detalles del Repositorio',
      child: Column(
        children: [
          ModernTextField(
            controller: _repoController,
            labelText: 'URL del Repositorio',
            onChanged: (value) {
              setState(() {
                _currentRepository = _currentRepository.copyWith(repo: value);
              });
            },
            validator: (value) {
              if (value?.isEmpty ?? true) return 'La URL es requerida';
              return null;
            },
          ),
          const SizedBox(height: 16),
          ModernTextField(
            controller: _repoBranchController,
            labelText: 'Rama',
            onChanged: (value) {
              setState(() {
                _currentRepository = _currentRepository.copyWith(branch: value);
              });
            },
          ),
          const SizedBox(height: 16),
          ModernTextField(
            controller: _repoImageController,
            labelText: 'Nombre de Imagen',
            onChanged: (value) {
              setState(() {
                _currentRepository = _currentRepository.copyWith(
                  repoImageName: value,
                );
              });
            },
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
                value: _currentRepository.requireAuth,
                onChanged: (value) {
                  setState(() {
                    _currentRepository =
                        _currentRepository.copyWith(requireAuth: value);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArgumentsSection() {
    return const SizedBox();
    // return _buildSection(
    //   title: 'Argumentos',
    //   child: RepositoryArgumentsSelector(
    //     availableArguments: widget.repository.instructions,
    //     currentArgument: _repositoryArguments,
    //     onArgumentsChanged: (newArguments) {
    //       setState(() {
    //         _repositoryArguments = newArguments;
    //       });
    //     },
    //   ),
    // );
  }

  Widget _buildEnvironmentVarsSection() {
    return _buildSection(
      title: 'Variables de Entorno',
      child: EnvironmentVarsList(
        repo: widget.repository,
        environmentVars: _repositoryArguments.environmentVars,
        onEnvironmentVarsChanged: (newVars) {
          setState(() {
            _repositoryArguments =
                _repositoryArguments.copyWith(environmentVars: newVars);
          });
        },
      ),
    );
  }

  Widget _buildCommandsSection() {
    return _buildSection(
      title: 'Comandos de Post-Clonación',
      child: CommandsList(
        commands: _repositoryArguments.steps,
        onCommandsChanged: (newCommands) {
          setState(() {
            _repositoryArguments = _repositoryArguments.copyWith(
              steps: newCommands,
            );
          });
        },
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'JetBrains Mono NF',
              fontFamilyFallback: ['Monospace', 'Consolas'],
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: 100,
      child: GradientActionButton(
        icon: Icons.update_rounded,
        label: 'Actualizar Repositorio',
        enabled: true,
        onPressed: _updateRepository,
        enabledGradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF64DD17)],
        ),
        width: double.infinity,
      ),
    );
  }

  void _updateRepository() {
    if (_formKey.currentState?.validate() ?? false) {
      // Usar el RepositoryBloc para actualizar
      _currentRepository.instructions[argIndex] = _repositoryArguments;
      context.read<RepositoryBloc>().add(
            UpdateRepository(
              _currentRepository.copyWith(updatedAt: DateTime.now()),
              true,
            ),
          );
      Navigator.pop(context);
    }
  }
}
