import 'dart:async';
import 'dart:io';

import 'package:auto_deployment/src/domain/services/required_services.dart';

import '../../../domain/enums/deployment_status.dart';

class DockerInstallationChecker
    extends RequiredServices<void, (bool, DeploymentStatus)> {
  const DockerInstallationChecker._();

  static const DockerInstallationChecker instance =
      DockerInstallationChecker._();

  @override
  String get serviceKey => "docker-installation";

  @override
  String get serviceName => 'Docker/Docker Compose';

  @override
  Future<(bool, DeploymentStatus)> check(
    void d, {
    void Function(String)? log,
    void Function()? onFail,
    void Function()? onEnd,
  }) async {
    final bool hasDocker = await isDockerInstalled(log: log);
    final bool hasCompose = await isDockerComposeAvailable(log: log);
    return (
      (hasDocker && hasCompose),
      (hasDocker && hasCompose
          ? DeploymentStatus.ready
          : DeploymentStatus.requireDocker)
    );
  }

  // Verificar si Docker está instalado
  Future<bool> isDockerInstalled({void Function(String)? log}) async {
    try {
      final ProcessResult result = await Process.run('docker', ['--version']);
      if (result.exitCode == 0) {
        log?.call('✅ Docker encontrado: ${result.stdout}');
        return true;
      }
      return false;
    } catch (e) {
      log?.call('❌ Docker no está instalado o no está en el PATH');
      return false;
    }
  }

  // Verificar si docker-compose está disponible
  Future<bool> isDockerComposeAvailable({void Function(String)? log}) async {
    try {
      final result = await Process.run('docker-compose', ['--version']);
      if (result.exitCode == 0) {
        log?.call('✅ Docker Compose encontrado: ${result.stdout}');
        return true;
      }
      return false;
    } catch (e) {
      log?.call('❌ Docker Compose no disponible');
      return false;
    }
  }
}
