import 'dart:convert';
import 'dart:io';

import 'package:auto_deployment/src/data/repository/repo_provider_repository.dart';
import 'package:auto_deployment/src/data/services/docker/docker_installation_checker.dart';
import 'package:auto_deployment/src/domain/entities/deployment_preferences.dart';
import 'package:auto_deployment/src/domain/repository/repo_provider_repository.dart';
import 'package:auto_deployment/src/presentation/bloc/repository_bloc.dart';
import 'package:auto_deployment/src/presentation/deployment/drawer/menu_drawer.dart';
import 'package:auto_deployment/src/presentation/deployment/page_animator.dart';
import 'package:provider/provider.dart';
import '../data/services/db/database_provider.dart';
import '../data/services/docker/docker_deployment_verifier.dart';
import '../data/services/docker/docker_manager.dart';
import '../domain/entities/repository_selection.dart';
import '../domain/enums/deployment_status.dart';
import 'deployment/deployment_manager_screen.dart';
import 'deployment/widgets/request_credentials_dialog.dart';
import 'package:flutter/material.dart';

import 'repositories/repository_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<bool> _useFullBuild = ValueNotifier(
      DeploymentPreferences.getCachedDeploymentPreferences().preferFullBuild);
  final ValueNotifier<DrawerPage> _currentPageNotifier =
      ValueNotifier(DrawerPage.deployment);
  final RepoProviderRepository _repositoryProvider =
      RepoProviderRepositoryImpl();

  final ValueNotifier<bool> _cloneProjectAlways = ValueNotifier(
      DeploymentPreferences.getCachedDeploymentPreferences()
          .cloneFullProyectAlways);
  final ValueNotifier<DeploymentStatus> _status =
      ValueNotifier<DeploymentStatus>(DeploymentStatus.idle);
  Process? currentProcess;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepositoryBloc>().add(LoadRepositories());
      _checkDocker();
    });
    super.initState();
  }

  @override
  void dispose() {
    _useFullBuild.dispose();
    _cloneProjectAlways.dispose();
    _status.dispose();
    _currentPageNotifier.dispose();
    DeploymentProvider.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ValueListenableBuilder(
              valueListenable: _currentPageNotifier,
              builder: (
                BuildContext context,
                DrawerPage currentPage,
                Widget? child,
              ) {
                return ModernDrawer(
                  currentPage: currentPage,
                  onPageSelected: (s) {
                    _currentPageNotifier.value = s;
                  },
                  deploymentStatus: _status,
                );
              }),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ValueListenableBuilder<DrawerPage>(
                valueListenable: _currentPageNotifier,
                builder: (
                  BuildContext context,
                  DrawerPage currentPage,
                  Widget? child,
                ) {
                  return PageAnimator(
                    currentPage: currentPage,
                    animationType: PageAnimationType.fadeScale,
                    child: _buildCurrentPage(
                      currentPage,
                      context,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage(DrawerPage page, BuildContext context) {
    switch (page) {
      case DrawerPage.repositories:
        return RepositoriesScreen(key: ValueKey('repositories'));
      case DrawerPage.settings:
        return const SettingsScreen(key: ValueKey('settings'));
      default:
        return DockerDeploymentScreen(
          key: const ValueKey('deployment'),
          status: _status,
          useFullBuild: _useFullBuild,
          cloneProjectAlways: _cloneProjectAlways,
          repository: _repositoryProvider,
          checkStatus: _checkStatus,
          startDeployment: _startDeployment,
          stopDeployment: _stopDeployment,
        );
    }
  }

  Future<void> _checkDocker() async {
    final DockerService service = Provider.of<DockerService>(
      context,
      listen: false,
    );
    final (bool hasDocker, DeploymentStatus status) = await service
        .services[DockerInstallationChecker.instance.serviceKey]!
        .check(
      null,
      log: service.log,
    );
    _status.value = status;
    final Repository? selection =
        context.read<RepositoryBloc>().state.selection;
    if (hasDocker || status != DeploymentStatus.requireDocker) {
      //TODO: check deployment verifier
      if (selection != null) {
        final bool rep = await service
            .services[DockerDeploymentVerifier.instance.serviceKey]!
            .check(
          selection.repoImageName,
          log: service.log,
        );
        if (rep) {
          _status.value = DeploymentStatus.running;
          await _checkStatus();
        }
        if (!rep) _status.value = DeploymentStatus.ready;
      }
      return;
    }
    service.log('❌ Por favor, asegurate de tener instalado '
        'Docker y Docker Compose en tu sistema');
  }

  Future<void> _startDeployment() async {
    final DockerService service = Provider.of<DockerService>(
      context,
      listen: false,
    );
    final Repository? selection =
        context.read<RepositoryBloc>().state.selection;
    if (selection == null) {
      service.log('Please select a '
          'repository first.');
      return;
    }
    service.reload();

    final bool existImage = await service
        .services[DockerDeploymentVerifier.instance.serviceKey]!
        .check(
      selection.repoImageName,
    );
    if (_cloneProjectAlways.value || !existImage) {
      if (!existImage && !_cloneProjectAlways.value) {
        service.log(
          'Clonando repositorio debido '
          'a que no existe la imagen '
          'en la ruta esperada',
        );
      }
      _status.value = DeploymentStatus.cloning;

      String username = "";
      String token = "";
      bool canceled = false;
      bool submitted = true;
      if (selection.requireAuth) {
        submitted = await showDialog<bool>(
              // ignore: use_build_context_synchronously
              context: context,
              barrierDismissible: false,
              builder: (BuildContext ctx) {
                return CredentialsRequestDialog(
                  onSubmit: (String cUser, String cToken) {
                    username = cUser;
                    token = cToken;
                  },
                  onCancel: () => canceled = true,
                );
              },
            ) ??
            false;
      }

      if (!submitted || canceled) {
        _status.value = DeploymentStatus.ready;
        service.log('Cloning canceled');
        return;
      }

      // 1. Clonar repositorio
      final bool cloned = await service.cloneRepository(
        selection.repo,
        branch: selection.branch,
        imageName: selection.repoImageName,
        username: username,
        token: token,
        onRequestSudoPermissions: () {
          return ('', '', false);
        },
        onEndProcess: () => currentProcess = null,
        onLoadProcess: (Process pr) {
          currentProcess = pr;
          pr.stdout
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen((line) {
            if (line.contains('remote:') &&
                service.lastMessage()!.contains('remote:')) {
              service.logClamp(
                service.logLength() - 1,
                service.logLength(),
              );
            }
            if (line.contains('Recibiendo objetos:') &&
                service.lastMessage()!.contains('Recibiendo objetos:')) {
              service.logClamp(
                service.logLength() - 1,
                service.logLength(),
              );
            }
            if (line.contains('deltas') &&
                service.lastMessage()!.contains('deltas')) {
              service.logClamp(
                service.logLength() - 1,
                service.logLength(),
              );
            }
            service.log(line);
          });
          // por alguna razón que no entiendo, git devuelve
          // estos logs aquí
          pr.stderr
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen((line) {
            if (line.contains('remote:') &&
                service.lastMessage()!.contains('remote:')) {
              service.logClamp(
                service.logLength() - 1,
                service.logLength(),
              );
            }
            if (line.contains('Recibiendo objetos:') &&
                service.lastMessage()!.contains('Recibiendo objetos:')) {
              service.logClamp(
                service.logLength() - 1,
                service.logLength(),
              );
            }
            if (line.contains('deltas') &&
                service.lastMessage()!.contains('deltas')) {
              service.logClamp(
                service.logLength() - 1,
                service.logLength(),
              );
            }
            service.log(line);
          });
        },
      );
      if (!cloned) {
        _status.value = DeploymentStatus.ready;
        return;
      }
    }

    // 2. Iniciar docker-compose
    _status.value = DeploymentStatus.running;

    final bool started = await service.startDockerCompose(
      _useFullBuild.value,
      imageName: selection.repoImageName,
      onRequestSudo: () async {
        String? token;
        await showDialog<void>(
          context: context,
          builder: (ctx) => CredentialsRequestDialog(
            onSubmit: (_, pass) => token = pass,
            onCancel: () {},
          ),
        );
        return token;
      },
      onFail: (Directory dir) async {},
    );

    if (!started) {
      _status.value = DeploymentStatus.error;
    }
    setState(() {});
  }

  Future<void> _stopDeployment() async {
    final DockerService service = Provider.of<DockerService>(
      context,
      listen: false,
    );
    final Repository? selection =
        context.read<RepositoryBloc>().state.selection;
    if (currentProcess != null) {
      service.log(
        'Deteniendo (${selection?.repoImageName})'
        'proceso actual ${currentProcess?.pid}',
      );
      currentProcess?.kill();
      service.isRunning.value = false;
    } else {
      service.log(
        'Deteniendo el '
        'contenedor '
        '`${selection?.repoImageName}`',
      );
      // when process is not null
      // means that were still cloning the project
      await service.stopDockerCompose(imageName: selection!.repoImageName);
    }

    _status.value = DeploymentStatus.ready;
  }

  Future<void> _checkStatus() async {
    final DockerService service = Provider.of<DockerService>(
      context,
      listen: false,
    );
    final Repository? selection =
        context.read<RepositoryBloc>().state.selection;
    service.reload();
    if (selection == null) {
      service.log(
        'No se puede '
        'revisar el '
        'estado de los contenedores si no '
        'hay ninguno seleccionado',
      );
      return;
    }
    final Map<String, String> status =
        await service.getContainerStatus(selection.repoImageName);

    if (status.isNotEmpty) {
      service.log('📊 Estado de los contenedores:');
      status.forEach((String serviceStatus, String state) {
        service.log('   $serviceStatus: $state');
      });
      _status.value = DeploymentStatus.ready;
      return;
    }
    service.log(
      '📊 No se encontraron contenedores en ejecución',
    );
    _status.value = DeploymentStatus.ready;
    setState(() {});
  }
}
