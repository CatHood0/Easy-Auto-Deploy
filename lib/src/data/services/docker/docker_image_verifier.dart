import 'dart:io';

import 'package:auto_deployment/src/data/services/docker/docker_manager.dart';
import 'package:auto_deployment/src/domain/services/required_services.dart';

class DockerImageVerifier extends RequiredServices<String, bool> {
  const DockerImageVerifier._();

  static const DockerImageVerifier instance = DockerImageVerifier._();

  @override
  String get serviceKey => 'docker-container-resolver';

  @override
  String get serviceName => 'Docker/Docker Compose';

  @override
  Future<bool> check(
    String imageName, {
    void Function(String p1)? log,
    void Function()? onFail,
    void Function()? onEnd,
  }) async {
    try {
      log?.call('🔎 Verificando si la imagen "$imageName" ya existe...');

      final bool exist = await checkDockerComposeFileExistence(
        await DockerService.appDirectory(imageName),
        canLog: false,
        log: log,
        onFail: onFail,
        onEnd: onEnd,
      );

      if (exist) {
        // Si stdout no está vacío, significa que el comando encontró un ID de imagen.
        log?.call(
          '✅ La imagen "$imageName" '
          'fue encontrada localmente.',
        );
        return true;
      } else {
        // Si el comando falla, loguea el error.
        log?.call('❌ Error al verificar la imagen');
        return false;
      }
    } catch (e) {
      log?.call(
        '❌ Ocurrió una excepción al verificar la imagen de Docker: $e',
      );
      return false;
    }
  }

  Future<bool> checkDockerComposeFileExistence(
    String path, {
    bool canLog = true,
    void Function(
      String,
    )? log,
    void Function()? onFail,
    void Function()? onEnd,
  }) async {
    final File composeFile = File('$path/docker-compose.yml');
    if (!await composeFile.exists()) {
      log?.call('❌ No se encontró docker-compose.yml en el repositorio');
      onFail?.call();
      return false;
    }
    onEnd?.call();
    return true;
  }
}
