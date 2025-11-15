import 'dart:io';

import 'package:auto_deployment/src/data/services/docker/docker_image_verifier.dart';
import 'package:auto_deployment/src/domain/services/required_services.dart';

//TODO: we need to find a way to subscribe to the current running image
// and pass the logs stored in stdout/stderr, since we need to retrieve
// them to the UI
class DockerDeploymentVerifier extends RequiredServices<String, bool> {
  const DockerDeploymentVerifier._();

  static const DockerDeploymentVerifier instance = DockerDeploymentVerifier._();

  @override
  String get serviceKey => 'docker-deployment-verifier';

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
      log?.call('🎯 Verificando despliegue de: $imageName');

      // 1. Verificar si la imagen existe localmente
      if (!await DockerImageVerifier.instance.check(
        imageName,
        log: log,
        onFail: onFail,
        onEnd: onEnd,
      )) {
        log?.call('❌ La imagen no existe localmente: $imageName');
        onFail?.call();
        return false;
      }

      // 2. Verificar si hay contenedores ejecutándose
      final List<Map<String, String>> runningContainers =
          await getRunningContainersByImage(
        imageName,
        log: log,
        onFail: onFail,
        onEnd: onEnd,
      );

      if (runningContainers.isNotEmpty) {
        log?.call('✅ Despliegue exitoso. Contenedores en ejecución:');
        for (final container in runningContainers) {
          log?.call('   📦 ${container['name']}'
              '  - ${container['status']}'
              ' - ${container['ports']}');
        }
        onEnd?.call();
        return true;
      } else {
        log?.call('⚠️ La imagen existe pero no hay contenedores ejecutándose');

        // Verificar si hay contenedores detenidos
        final allContainers = await Process.run('docker', [
          'ps',
          '-a',
          '--filter',
          'ancestor=$imageName',
          '--format',
          '{{.Names}}|{{.Status}}'
        ]);

        if (allContainers.exitCode == 0 &&
            allContainers.stdout.toString().trim().isNotEmpty) {
          log?.call('📋 Contenedores existentes (pueden estar detenidos):');
          final lines = allContainers.stdout.toString().trim().split('\n');
          for (final line in lines) {
            log?.call('   📦 $line');
          }
        }

        onEnd?.call();
        return true;
      }
    } catch (e) {
      onFail?.call();
      log?.call('❌ Error en verificación de despliegue: $e');
      return false;
    }
  }

  /// Obtiene información detallada de contenedores por imagen
  Future<List<Map<String, String>>> getRunningContainersByImage(
    String imageName, {
    void Function(
      String,
    )? log,
    void Function()? onFail,
    void Function()? onEnd,
  }) async {
    try {
      final result = await Process.run('docker', [
        'ps',
        '--filter',
        'ancestor=$imageName',
        '--format',
        '{{.Names}}|{{.ID}}|{{.Status}}|{{.Ports}}'
      ]);

      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        final containers = <Map<String, String>>[];
        final lines = result.stdout.toString().trim().split('\n');

        for (final line in lines) {
          final parts = line.split('|');
          if (parts.length >= 4) {
            containers.add({
              'name': parts[0],
              'id': parts[1],
              'status': parts[2],
              'ports': parts[3],
              'image': imageName,
            });
          }
        }

        return containers;
      }

      return [];
    } catch (e) {
      log?.call('❌ Error obteniendo información de contenedores: $e');
      return [];
    }
  }
}
