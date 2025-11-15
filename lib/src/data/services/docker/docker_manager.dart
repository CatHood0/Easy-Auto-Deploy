import 'dart:async';
import 'dart:io';
import 'dart:convert';

import '../../services/docker/docker_image_verifier.dart';
import '../../services/git/git_installation_checker.dart';
import '../../services/git/network_error.dart';
import '../../../domain/services/required_services.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_package;
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/permission_issue.dart';
import '../../../domain/enums/deployment_status.dart';
import '../../../domain/enums/docker_permissions.dart';
import '../../../domain/enums/issue_severity.dart';
import '../git/git_clone_resolver.dart';
import '../services.dart';
import 'docker_deployment_verifier.dart';

class DockerService {
  DockerService(this._logger);
  final Map<String, RequiredServices> services = <String, RequiredServices>{
    DockerInstallationChecker.instance.serviceKey:
        DockerInstallationChecker.instance,
    DockerImageVerifier.instance.serviceKey: DockerImageVerifier.instance,
    DockerDeploymentVerifier.instance.serviceKey:
        DockerDeploymentVerifier.instance,
    DockerIssues.instance.serviceKey: DockerIssues.instance,
    GitInstallationChecker.instance.serviceKey: GitInstallationChecker.instance,
    GitCloneIssueResolver.instance.serviceKey: GitCloneIssueResolver.instance,
    NetworkIssueResolver.instance.serviceKey: NetworkIssueResolver.instance,
  };
  final LoggerService _logger;

  /// Whether the current service is running
  ///
  /// Tipically is auto-managed by the class,
  /// but we require sometimes access to this
  /// to disable it
  final ValueNotifier<bool> isRunning = ValueNotifier<bool>(false);

  Stream<List<String>> get logs => _logger.logs;

  void reload() => _logger.clamp(0, _logger.length);

  void log(String message) => _logger.log(message);
  void logClamp(int start, int end) => _logger.clamp(start, end);

  int logLength() => _logger.length;

  String? lastMessage() => _logger.last;

  /// Verifica los permisos antes de cualquier operación
  Future<bool> checkPermissions() async {
    _logger.log('🔐 Verificando requisitos del sistema...');

    final (DockerPermissionStatus status, String provider) =
        await validateDockerPermissions(kDebugMode);

    if (status == DockerPermissionStatus.valid) {
      _logger.log('✅ Sistema verificado ($provider) correctamente');
      return true;
    } else {
      final PermissionIssue issue = await getPermissionIssue();
      _logger.log('❌ Problema de configuración '
          'detectado con el proveedor $provider');
      _logger.log('📋 ${issue.title}');
      _logger.log('📝 ${issue.description}');
      return false;
    }
  }

  Future<List<PermissionIssue>> checkPotentialIssues(
      {void Function(String)? log}) async {
    final List<PermissionIssue> issues = [];

    log?.call('🔍 Realizando verificación...');

    // Verificar problemas de red
    final bool networkStatus =
        await services[NetworkIssueResolver.instance.serviceKey]!.check(
      null,
      log: log,
    );
    if (!networkStatus) {
      issues.add(
        await getPermissionIssue(
          DockerPermissionStatus.notServiceInstalled,
          NetworkIssueResolver.instance.serviceKey,
        ),
      );
    }

    // Verificar problemas de clonación Git
    final bool gitCloneStatus =
        await services[GitCloneIssueResolver.instance.serviceKey]!.check(
      null,
      log: log,
    );

    if (!gitCloneStatus) {
      issues.add(
        await getPermissionIssue(
          DockerPermissionStatus.notServiceInstalled,
          GitCloneIssueResolver.instance.serviceKey,
        ),
      );
    }

    if (issues.isEmpty) {
      log?.call('✅ No se detectaron problemas potenciales');
    } else {
      log?.call('⚠️ Se detectaron ${issues.length} problemas potenciales');
    }

    return issues;
  }

  // Clonar el repositorio
  Future<bool> cloneRepository(
    String repoUrl, {
    String branch = 'main',
    required String imageName,
    required String username,
    required String token,
    (String, String, bool) Function()? onRequestSudoPermissions,
    void Function(Process pr)? onLoadProcess,
    void Function()? onEndProcess,
  }) async {
    try {
      // check if git exist first
      if (!(await services[GitInstallationChecker.instance.serviceKey]!.check(
        null,
        log: (String value) {
          _logger.log(value);
        },
      )).$1) {
        isRunning.value = false;
        return false;
      }

      _logger.log('📥 Clonando repositorio: $repoUrl');
      isRunning.value = true;
      final Uri uri = Uri.parse(repoUrl);
      final String authUrl = 'https://'
          '${username.isEmpty && token.isEmpty ? '' : '$username:$token@'}'
          '${uri.host}'
          '${uri.path}';

      final Directory dir = Directory(await appDirectory(imageName));

      // since we cannot force cloning in the same dir, we need
      // to remove that directory directly
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      final Process process = await Process.start('git', [
        // disable ssh and certificates checking
        '-c',
        'http.sslVerify=false',
        'clone',
        '--progress', // Show progress
        '--depth',
        '1',
        '-b',
        branch,
        authUrl,
        dir.path,
      ]);
      // Escuchar la salida estándar y de errores para logging en tiempo real

      onLoadProcess?.call(process);

      final int exitCode = await process.exitCode;

      if (exitCode == 0) {
        isRunning.value = false;
        onEndProcess?.call();
        _logger.log(
          'Clone [INFO]: ✅ '
          'Repositorio clonado exitosamente',
        );
        return true;
      } else {
        isRunning.value = false;
        onEndProcess?.call();
        _logger.log(
          'Clone [Error]: ❌ No se pudo clonar el '
          'repositorio. El proceso terminó con código de salida: $exitCode',
        );
        return false;
      }
    } catch (e) {
      isRunning.value = false;
      onEndProcess?.call();
      _logger.log('❌ Error clonando: $e');
      return false;
    }
  }

  // Ejecutar docker-compose up
  Future<bool> startDockerCompose(
    bool fullBuild, {
    required String imageName,
    required void Function(Directory) onFail,
    required Future<String?> Function()? onRequestSudo,
    List<String> launchOptions = const <String>[],
  }) async {
    isRunning.value = true;
    _logger.log('🚀 Iniciando docker-compose...');
    final String path = await appDirectory(imageName);

    try {
      final bool hasPermissions = await checkPermissions();
      if (!hasPermissions) {
        _logger.log('🚫 No se puede continuar debido a problemas de permisos');
        return false;
      }

      final ProcessResult containerCheck =
          await Process.run('docker', ['run', '--rm', 'hello-world']);
      String? sudoToken;

      // we require sudo
      if (containerCheck.exitCode != 0 ||
          containerCheck.stderr != null &&
              containerCheck.stderr.isNotEmpty &&
              containerCheck.stderr.contains('permission denied')) {
        sudoToken = await onRequestSudo?.call();
        if (sudoToken == null || sudoToken.isEmpty) {
          _logger.log('🚫 Credenciales inválidas, no se podrá ejecutar '
              'la imagen sin permisos de superusuario');
          return false;
        }
      }

      final bool exist =
          await DockerImageVerifier.instance.checkDockerComposeFileExistence(
        path,
        log: (value) {
          _logger.log(value);
        },
        onFail: () {
          isRunning.value = false;
        },
      );
      if (exist) {
        return false;
      }

      // Ejecutar docker-compose up en segundo plano
      final Process process = await Process.start(
        'docker-compose',
        [
          'up',
          if (fullBuild) '--build',
          if (fullBuild) '--no-cache',
          ...launchOptions,
        ],
        workingDirectory: path,
        runInShell: true,
      );

      process.stdout
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((line) {
        _logger.log('📦 $line');
      });

      process.stderr
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((line) {
        _logger.log('⚠️ $line');
      });

      process.exitCode.then((code) {
        isRunning.value = false;
        if (code == 0) {
          _logger.log('✅ docker-compose terminó exitosamente');
        } else {
          _logger.log('❌ docker-compose terminó con código de error: $code');
        }
      });

      return true;
    } catch (e) {
      _logger.log('❌ Error iniciando docker-compose: $e');
      return false;
    } finally {
      isRunning.value = false;
      onFail(Directory(path));
    }
  }

  // Detener los contenedores
  Future<bool> stopDockerCompose({
    required String imageName,
  }) async {
    try {
      _logger.log('🛑 Deteniendo contenedores...');

      final String path = await appDirectory(imageName);
      final ProcessResult result = await Process.run(
        'docker-compose',
        ['down'],
        workingDirectory: path,
      );

      if (result.exitCode == 0) {
        _logger.log('✅ Contenedores detenidos');
        return true;
      } else {
        _logger.log('❌ Error deteniendo contenedores: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.log('❌ Error deteniendo docker-compose: $e');
      return false;
    } finally {
      isRunning.value = false;
    }
  }

  // Verificar estado de los contenedores
  Future<Map<String, String>> getContainerStatus(String imageName) async {
    try {
      final result = await Process.run(
        'docker-compose',
        ['ps', '--format', 'json'],
        workingDirectory: await appDirectory(imageName),
        runInShell: true,
      );

      if (result.exitCode == 0 && result.stdout.toString().isNotEmpty) {
        final Map<String, String> services = <String, String>{};
        final List<String> lines = result.stdout.toString().trim().split('\n');

        for (int i = 0; i < lines.length; i++) {
          final String line = lines[i];
          try {
            final service = json.decode(line);
            services[service['Service']] = service['State'];
          } catch (e) {
            // Ignorar líneas que no son JSON válido
          }
        }

        return services;
      }

      return {};
    } catch (e) {
      return {};
    }
  }

  Future<List<(DockerPermissionStatus, String)>>
      validateListDockerPermissions() async {
    final List<(DockerPermissionStatus, String)> issues =
        <(DockerPermissionStatus, String)>[];
    //TODO: make these steps more readable
    try {
      final dockerCheck = await Process.run('docker', ['--version']);
      // print('Docker check Result: ${dockerCheck.stdout}');
      if (dockerCheck.exitCode != 0) {
        issues.add((
          DockerPermissionStatus.notInstalled,
          DockerInstallationChecker.instance.serviceKey
        ));
      }
      final dockerComposeCheck =
          await Process.run('docker-compose', ['--version']);
      // print('Docker Result: ${dockerComposeCheck.stdout}');
      if (dockerComposeCheck.exitCode != 0 ||
          dockerComposeCheck.stderr != null &&
              dockerComposeCheck.stderr.isNotEmpty) {
        issues.add((
          DockerPermissionStatus.notInstalledCompose,
          '${DockerInstallationChecker.instance.serviceKey}-compose'
        ));
      }

      // Paso 2: Verificar si puede comunicarse con el daemon de Docker
      final ProcessResult pingResult = await Process.run('docker', ['info']);
      // print('Result: ${pingResult.stdout}');
      if (pingResult.exitCode != 0 ||
          pingResult.stderr != null && pingResult.stderr.isNotEmpty) {
        issues.add((
          DockerPermissionStatus.notRunningDocker,
          'Docker-Daemon',
        ));
      }
      // Paso 3: Verificar si puede crear contenedores
      final ProcessResult containerCheck = await Process.run('docker', [
        'run',
        '--rm',
        'hello-world',
      ]);

      if (containerCheck.exitCode != 0 ||
          containerCheck.stderr != null &&
              containerCheck.stderr.contains(
                'docker: permission denied',
              )) {
        issues.add((
          DockerPermissionStatus.noPermission,
          'docker-permissions',
        ));
      }
    } catch (e) {
      issues.add((DockerPermissionStatus.unknownError, 'validation-error'));
    }
    return issues.toList();
  }

  /// Valida si el usuario tiene permisos completos para Docker
  /// Retorna true si puede crear y ejecutar contenedores sin problemas
  Future<(DockerPermissionStatus, String)> validateDockerPermissions([
    bool ignoreLogs = false,
  ]) async {
    _logger.log('🔍 Validando permisos de Docker...', ignoreLogs);
    //TODO: should we create a loop traversing into the map instead
    // calling direct services? idk

    try {
      // Paso 1: Verificar si git está instalado
      _logger.log('Verificando la instalación de Git...', ignoreLogs);
      final (bool gitCheck, DeploymentStatus _) =
          await services[GitInstallationChecker.instance.serviceKey]!.check(
        null,
        log: _logger.log,
      );
      if (!gitCheck) {
        return (
          DockerPermissionStatus.notServiceInstalled,
          GitInstallationChecker.instance.serviceKey,
        );
      }
      // Paso 2: Verificar si Docker está instalado
      _logger.log('Verificando instalación de Docker...', ignoreLogs);
      final dockerCheck = await Process.run('docker', ['--version']);
      if (dockerCheck.exitCode != 0) {
        _logger.log(
            '❌ Docker no está instalado o no está en el PATH', ignoreLogs);
        return (
          DockerPermissionStatus.notInstalled,
          DockerInstallationChecker.instance.serviceKey
        );
      }
      _logger.log('✅ Docker está instalado: ${dockerCheck.stdout}', ignoreLogs);

      // Paso 2: Verificar si Docker está instalado
      _logger.log('Verificando instalación de Docker Compose...', ignoreLogs);
      final dockerComposeCheck =
          await Process.run('docker-compose', ['--version']);
      if (dockerComposeCheck.exitCode != 0) {
        _logger.log(
          '❌ Docker Compose no está instalado o no está en el PATH',
          ignoreLogs,
        );
        return (
          DockerPermissionStatus.notInstalledCompose,
          '${DockerInstallationChecker.instance.serviceKey}-compose',
        );
      }
      _logger.log(
          '✅ Docker Compose está instalado: ${dockerCheck.stdout}', ignoreLogs);

      // Paso 3: Verificar si puede comunicarse con el daemon de Docker
      _logger.log(
          'Verificando conexión con el daemon de Docker...', ignoreLogs);
      final pingResult = await Process.run('docker', ['info']);
      if (pingResult.exitCode != 0) {
        _logger.log('❌ No se puede conectar al daemon de Docker', ignoreLogs);
        return (DockerPermissionStatus.notRunningDocker, 'Docker-Daemon');
      }
      _logger.log('✅ Conexión al daemon establecida', ignoreLogs);

      // Paso 4: Verificar docker-compose
      _logger.log('Verificando docker-compose...', ignoreLogs);
      final composeCheck = await Process.run('docker-compose', ['--version']);
      if (composeCheck.exitCode != 0) {
        _logger.log('⚠️ docker-compose no está disponible', ignoreLogs);
        // No es crítico, podemos intentar con 'docker compose'
      } else {
        _logger.log(
            '✅ docker-compose disponible: ${composeCheck.stdout}', ignoreLogs);
      }

      // Paso 4: Verificar si puede crear contenedores
      _logger.log('Verificando creación de contenedores...', ignoreLogs);
      final containerCheck = await Process.run('docker', [
        'run',
        '--rm',
        'hello-world',
      ]);

      if (containerCheck.exitCode != 0 ||
          containerCheck.stderr != null &&
              containerCheck.stderr.contains('docker: permission denied')) {
        _logger.log('❌ No se pueden crear contenedores', ignoreLogs);
        return (
          DockerPermissionStatus.noPermission,
          'docker-permissions',
        );
      }
      _logger.log('✅ Creación de contenedores verificada', ignoreLogs);

      _logger.log(
          '🎉 Todos los permisos de Docker están configurados correctamente',
          ignoreLogs);
      return (
        DockerPermissionStatus.valid,
        DockerInstallationChecker.instance.serviceKey
      );
    } catch (e) {
      _logger.log('❌ Error durante la validación: $e', ignoreLogs);
      return (DockerPermissionStatus.unknownError, 'validation-Error');
    }
  }

  /// Obtiene información detallada sobre el problema de permisos
  Future<List<PermissionIssue>> getListOfPermissionIssues([
    bool ignoreNoIssues = true,
  ]) async {
    final List<(DockerPermissionStatus, String)> dockerPermissions =
        await validateListDockerPermissions();

    final List<PermissionIssue> issues = [...await checkPotentialIssues()];
    for (var issue in dockerPermissions) {
      if (issue.$1 == DockerPermissionStatus.valid) continue;
      issues.add(
        await getPermissionIssue(
          issue.$1,
          issue.$2,
        ),
      );
    }
    return issues;
  }

  /// Obtiene información detallada sobre el problema de permisos
  Future<PermissionIssue> getPermissionIssue([
    DockerPermissionStatus? dockerStatus,
    String? provider,
  ]) async {
    DockerPermissionStatus? status = dockerStatus;

    // we need to avoid calling validateListDockerPermissions when needed
    // since it can create an infinite recursive loop
    if (dockerStatus == null && provider == null) {
      final (s, prov) = await validateDockerPermissions();

      dockerStatus ??= s;
      provider ??= prov;
    }

    switch (status!) {
      case DockerPermissionStatus.valid:
        return PermissionIssue(
          severity: IssueSeverity.none,
          title: 'Permisos correctos',
          description:
              'El usuario tiene todos los permisos necesarios para Docker',
          solution: 'No se requiere acción',
        );

      case DockerPermissionStatus.notServiceInstalled:
        final String name = services.values
            .firstWhere((
              RequiredServices p,
            ) =>
                p.serviceKey == provider)
            .serviceName;
        return PermissionIssue(
          severity: IssueSeverity.none,
          title: '$name es necesario',
          description:
              'El servicio de $name no está instalado en el sistema operativo',
          solution: await services[DockerIssues.instance.serviceKey]!.check(
            provider,
          ),
        );

      case DockerPermissionStatus.notRunningDocker:
        final String name = services.values
            .firstWhere((
              RequiredServices p,
            ) =>
                p.serviceKey == provider)
            .serviceName;
        return PermissionIssue(
          severity: IssueSeverity.warning,
          title: '$name es necesario',
          description:
              'El servicio de $name no está instalado en el sistema operativo',
          solution: await services[DockerIssues.instance.serviceKey]!.check(
            provider,
          ),
        );

      case DockerPermissionStatus.notInstalled:
        return PermissionIssue(
          severity: IssueSeverity.critical,
          title: 'Docker no instalado',
          description:
              'Docker no está instalado en el sistema o no está en el PATH',
          solution: await DockerIssues.instance.check(provider!),
        );

      case DockerPermissionStatus.notInstalledCompose:
        return PermissionIssue(
          severity: IssueSeverity.critical,
          title: 'Docker Compose no instalado',
          description:
              'Docker Compose no está instalado en el sistema o no está en el PATH',
          solution: await services[DockerIssues.instance.serviceKey]!.check(
            provider,
          ),
        );

      case DockerPermissionStatus.noPermission:
        return PermissionIssue(
          severity: IssueSeverity.critical,
          title: 'Permisos insuficientes',
          description: 'El usuario actual no tiene permisos para usar Docker',
          solution: await DockerIssues.instance.check(provider!),
        );

      case DockerPermissionStatus.unknownError:
        return PermissionIssue(
          severity: IssueSeverity.critical,
          title: 'Error desconocido',
          description: 'Ocurrió un error inesperado durante la validación',
          solution: await DockerIssues.instance.check(provider!),
        );
    }
  }

  static Future<String> appDirectory(String name, {String? path}) async {
    final Directory dir =
        path != null ? Directory('') : await getApplicationCacheDirectory();
    return path_package.join(
      path ?? dir.path,
      name,
    );
  }
}
