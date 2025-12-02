/* Copyright (C) S. CatHood0 - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by CatHood0 <cathood@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

import '../../docker2.dart';
import 'compose_volumes.dart';
import 'exceptions.dart';

/// Top level class generally used as the starting point manage
/// docker compose containers.
class DockerCompose {
  /// Starts and mount the docker container and the internal
  /// services defined in docker-compose.yaml
  /// (only creates if [buildImage] is true).
  Progress up({
    required String workspaceDirectory,
    bool daemon = true,
    bool buildImage = true,
    bool background = false,
    bool forceStopIfRunning = false,
    String? argString,
    Image? image,
    List<String>? args,
    List<String> environmentVars = const <String>[],
    Progress? pr,
  }) {
    String cmdArgs = '';

    if (args != null) {
      cmdArgs += ' ${args.join(' ')}';
    }
    if (argString != null) {
      cmdArgs += ' $argString';
    }

    if (background) {
      cmdArgs += ' -d';
    }

    if (forceStopIfRunning) {
      cmdArgs += ' --force-recreate';
    }

    final StringBuffer envVars = StringBuffer();
    if (environmentVars.isNotEmpty) {
      for (final String env in environmentVars) {
        envVars.write('-e $env ');
      }
    }

    bool terminal = false;
    if (!daemon) {
      cmdArgs = '--attach --interactive $cmdArgs';
      terminal = true;
    }
    return dockerComposeRun(
      'up',
      '$cmdArgs $envVars -y '
              '${!buildImage ? '--no-build' : '--build'} '
              '${image?.fullname ?? ''}'
          .trim(),
      terminal: terminal,
      workspaceDirectory: workspaceDirectory,
      pr: pr,
    );
  }

  /// Starts and creates a docker container (only creates if [buildImage] is true).
  Progress run({
    required String workspaceDirectory,
    bool daemon = true,
    bool buildImage = true,
    bool background = false,
    bool servicePorts = true,
    bool removeOnExist = false,
    String? argString,
    Image? image,
    List<String>? args,
    List<String> environmentVars = const <String>[],
    Progress? pr,
  }) {
    String cmdArgs = '';

    if (args != null) {
      cmdArgs += ' ${args.join(' ')}';
    }
    if (argString != null) {
      cmdArgs += ' $argString';
    }
    if (background) {
      cmdArgs += ' -d';
    }

    final StringBuffer envVars = StringBuffer();
    if (environmentVars.isNotEmpty) {
      for (final String env in environmentVars) {
        envVars.write('-e $env ');
      }
    }

    bool terminal = false;
    if (!daemon) {
      cmdArgs = '--attach --interactive $cmdArgs';
      terminal = true;
    }
    return dockerComposeRun(
      'run',
      '$cmdArgs $envVars -y '
              '${!buildImage ? '--no-build' : '--build'} '
              '${servicePorts ? '--service-ports' : ''} '
              '${removeOnExist ? '--rm' : ''} '
              '${image?.fullname ?? ''}'
          .trim(),
      terminal: terminal,
      workspaceDirectory: workspaceDirectory,
      pr: pr,
    );
  }

  /// Returns a list of containers
  /// If [excludeStopped] is true (defaults to false) then
  /// only running containers will be returned.
  List<Container> containers({
    required String workspaceDirectory,
    bool excludeStopped = false,
  }) =>
      Containers().containers(
        excludeStopped: excludeStopped,
        compose: true,
        workspaceDirectory: workspaceDirectory,
      );

  /// Returns the list of volumes
  List<Volume> volumes(String workspace) => ComposeVolumes().volumes(
        workspaceDirectory: workspace,
      );

  /// internal function to provide a consistent method of handling
  /// failed execution of the docker command.
  Progress _dockerComposeRun(
    String cmd,
    String args, {
    bool terminal = false,
    Progress? pr,
    String? workspaceDirectory,
  }) {
    final Progress progress = 'docker compose $cmd $args'.start(
      nothrow: true,
      terminal: terminal,
      progress: pr ?? Progress.capture(),
      workingDirectory: workspaceDirectory,
    );

    if (progress.exitCode != 0) {
      throw DockerCommandFailed(
        cmd,
        args,
        progress.exitCode!,
        progress.lines.join(
          '\n',
        ),
      );
    }
    return progress;
  }
}

/// runs the passed docker command.
Progress dockerComposeRun(
  String cmd,
  String args, {
  bool terminal = false,
  Progress? pr,
  String? workspaceDirectory,
}) =>
    DockerCompose()._dockerComposeRun(
      cmd,
      args,
      terminal: terminal,
      pr: pr,
      workspaceDirectory: workspaceDirectory,
    );
