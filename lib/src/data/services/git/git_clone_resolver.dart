import 'dart:io';

import '../../../domain/services/required_services.dart';

class GitCloneIssueResolver extends RequiredServices<void, bool> {
  const GitCloneIssueResolver._();

  static const GitCloneIssueResolver instance = GitCloneIssueResolver._();

  @override
  String get serviceKey => 'git-clone-resolver';

  @override
  String get serviceName => 'Git';

  @override
  Future<bool> check(
    void d, {
    void Function(String)? log,
    void Function()? onFail,
    void Function()? onEnd,
  }) async {
    log?.call('🔍 Verificando problemas de clonación Git...');

    try {
      final ProcessResult result = await Process.run('git', [
        'ls-remote',
        'https://github.com',
      ]);

      if (result.exitCode != 0) {
        return false;
      }
    } catch (e) {
      return false;
    }

    onEnd?.call();
    return true;
  }
}
