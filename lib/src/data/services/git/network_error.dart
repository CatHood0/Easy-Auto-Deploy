import 'dart:io';

import '../../../domain/services/required_services.dart';

class NetworkIssueResolver extends RequiredServices<void, bool> {
  const NetworkIssueResolver._();

  static const NetworkIssueResolver instance = NetworkIssueResolver._();

  @override
  String get serviceKey => 'network-error';

  @override
  String get serviceName => 'Internet';

  @override
  Future<bool> check(
    void d, {
    void Function(String)? log,
    void Function()? onFail,
    void Function()? onEnd,
  }) async {
    log?.call('🔍 Verificando conectividad de red...');

    // Verificar conectividad a internet
    try {
      final ProcessResult result =
          await Process.run('ping', ['-c', '1', '8.8.8.8']);
      if (result.exitCode != 0) {
        return false;
      }

      // Verificar acceso a Docker Hub
      final ProcessResult dockerResult =
          await Process.run('curl', ['-I', 'https://hub.docker.com']);
      if (dockerResult.exitCode != 0) {
        return false;
      }
    } catch (e) {
      return false;
    }

    onEnd?.call();
    return true;
  }
}
