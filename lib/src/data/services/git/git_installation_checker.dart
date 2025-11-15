import 'dart:async';
import 'dart:io';

import 'package:auto_deployment/src/domain/services/required_services.dart';

import '../../../domain/enums/deployment_status.dart';

class GitInstallationChecker
    extends RequiredServices<void, (bool, DeploymentStatus)> {
  const GitInstallationChecker._();

  static const GitInstallationChecker instance = GitInstallationChecker._();

  @override
  String get serviceKey => 'git-installation-checker';

  @override
  String get serviceName => 'Git';

  @override
  Future<(bool, DeploymentStatus)> check(
    void d, {
    void Function(String)? log,
    void Function()? onFail,
    void Function()? onEnd,
  }) async {
    try {
      final ProcessResult process = await Process.run('git', ['-v']);

      final int exitCode = process.exitCode;

      if (exitCode == 0) {
        log?.call(
          '✅ Git ya está instalado en el sistema'
          'Repositorio clonado exitosamente',
        );
        onEnd?.call();
        return (true, DeploymentStatus.ready);
      }
      log?.call(
        '❌ Git no está instalado',
      );
      onFail?.call();
      return (true, DeploymentStatus.requireExternalService);
    } catch (e) {
      log?.call('❌ No se pudo chequear si el sistema tiene git instalado');
      onFail?.call();
      return (false, DeploymentStatus.notWorking);
    }
  }
}
