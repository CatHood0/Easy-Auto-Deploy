import 'dart:convert';

import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';

import '../../docker2.dart';
import 'exceptions.dart';

/// A docker container.
@immutable
class Container {
  /// id of the container (the 12 char version)
  final String containerid;

  /// the id of the image this container is based on.
  final String imageid;

  /// the create date/time of this container.
  final String created;

  /// The status of this container.
  final String status;

  /// The ports used by this container
  final String ports;

  /// The name of this container.
  final String name;

  /// construct a docker container object from its parts.
  const Container({
    required this.containerid,
    required this.imageid,
    required this.created,
    required this.status,
    required this.ports,
    required this.name,
  });

  /// Creates a container from [image] binding the passed
  /// [Volume]s into the container.
  factory Container.create(
    Image image, {
    List<VolumeMount> volumes = const <VolumeMount>[],
    bool readonly = false,
  }) {
    final StringBuffer volarg = StringBuffer();
    if (volumes.isNotEmpty) {
      for (final VolumeMount mount in volumes) {
        final String readonlyArg = readonly ? ',readonly' : '';

        volarg.write("--mount 'type=volume,source=${mount.volume.name}"
            ",destination=${mount.mountPath}$readonlyArg'");
      }
    }
    final String containerid =
        dockerRun('container', 'create $volarg ${image.name}').lines.first;

    return Containers().findByContainerId(containerid)!;
  }

  /// Returns true if [other] has the same containerid as this
  /// container.
  /// We use the shorter 12 character version of the id.
  bool isSame(Container other) => containerid == other.containerid;

  @override
  bool operator ==(covariant Container other) {
    if (identical(this, other)) {
      return true;
    }

    if (containerid == other.containerid) {
      return true;
    }

    return false;
  }

  /// returns the list of volumes attached to this container.
  List<Volume> get volumes {
    final List<Volume> volumes = <Volume>[];

    final String line =
        dockerRun('inspect', '$containerid --format "{{json .Mounts}}"')
            .lines
            .first;

    if (line == '[]') {
      return volumes;
    }

    final List<dynamic> list = jsonDecode(line) as List<dynamic>;
    for (final dynamic v in list) {
      // it's json.
      // ignore: avoid_dynamic_calls
      final String type = v['Type'] as String;
      if (type == 'volume') {
        // it's json.
        // ignore: avoid_dynamic_calls
        final String name = v['Name']! as String;
        final Volume? volume = Volumes().findByName(name);
        if (volume == null) {
          throw UnknownVolumeException(
            'The container $containerid '
            'contains an unknown Volume $name',
          );
        }
        volumes.add(volume);
      }
    }

    return volumes;
  }

  @override
  int get hashCode => containerid.hashCode;

  /// returns the image based on this image's id.
  /// We actually refetch the list of images to ensure
  /// we have the complete set of details.
  Image? get image => Images().findByImageId(imageid);

  /// Tops the docker container if it is running.
  /// If the container is not running then no action is taken.
  bool stop({
    bool compose = false,
    String? workspaceDirectory,
  }) {
    if (isRunning) return true;
    if (compose) {
      assert(workspaceDirectory != null, 'workspaceDirectory must be defined');
      dockerComposeRun(
        'stop',
        '',
        workspaceDirectory: workspaceDirectory,
      );
      return isStopped;
    }
    dockerRun('stop', containerid);
    return isStopped;
  }

  /// Starts a docker container.
  /// If [daemon] is true (the default) then the container is started
  /// as a daemon. When [daemon] is false then we pass the interactive and
  /// attach arguments to the docker start command to allow full interaction.
  // Throws [ContainerAlreadyRunning] if the container is already running.
  ///
  /// The [args] and [argString] are appended to the command
  /// and allow you to add abitrary arguments.
  /// The [args] list is added before the [argString].
  void start({
    List<String>? args,
    String? argString,
    bool daemon = true,
    bool compose = false,
    String? workspaceDirectory,
  }) {
    if (isRunning) {
      throw ContainerAlreadyRunning();
    }

    String cmdArgs = '';

    if (args != null) {
      cmdArgs += ' ${args.join(' ')}';
    }
    if (argString != null) {
      cmdArgs += ' $argString';
    }

    bool terminal = false;
    if (!daemon) {
      cmdArgs = '--attach --interactive $cmdArgs';
      terminal = true;
    }

    if (compose) {
      dockerComposeRun(
        'start',
        cmdArgs,
        workspaceDirectory: workspaceDirectory,
      );
      return;
    }

    dockerRun('start', cmdArgs, terminal: terminal);
  }

  /// Returns true if the container is currently running.
  bool get isRunning =>
      dockerRun('container', "inspect -f '{{.State.Running}}' $containerid")
          .lines
          .first ==
      'true';

  /// Returns true if the container is currently stopped.
  bool get isStopped =>
      dockerRun('container', "inspect -f '{{.State.Running}}' $containerid")
          .lines
          .first ==
      'false';

  /// Kill the container process
  ///
  /// This feature is just supported by docker-compose
  @experimental
  bool kill({
    required String workspaceDirectory,
    bool compose = false,
    String? containerId,
  }) {
    if (compose) {
      assert(
        workspaceDirectory.isNotEmpty,
        'workspaceDirectory must '
        'have a valid path to be '
        'executed as expected',
      );
      dockerComposeRun(
        'kill',
        '-s SIGKILL',
        workspaceDirectory: workspaceDirectory,
      );
      return isStopped;
    }
    assert(
      containerId != null && containerId.isNotEmpty,
      'containerId must be defined when '
      'kill is executed by docker',
    );

    dockerRun(
      'container',
      'kill $containerId',
      workspaceDirectory: workspaceDirectory,
    );
    return isStopped;
  }

  /// deletes this docker container.
  Progress? delete({
    Progress? pr,
    bool compose = false,
    String? workspaceDir,
    bool removeVolumes = false,
  }) {
    if (compose) {
      assert(
        workspaceDir != null,
        'workspaceDirectory must '
        'be defined to delete a '
        'container with docker compose',
      );
      return dockerComposeRun(
        'rm',
        // stop services when required
        // don't ask for confirmation
        // and remove the volumes if [removeVolumes] is true
        '-s -f ${removeVolumes ? '-v' : ''}',
        workspaceDirectory: workspaceDir,
        pr: pr,
      );
    }
    return dockerRun(
      'container',
      'rm $containerid',
      pr: pr,
    );
  }

  /// writes this containers docker logs to the console
  /// If [limit] is 0 (the default) all log lines a output.
  /// If [limit] is > 0 then only the last [limit] lines are output.
  Progress? showLogs({
    int limit = 0,
    bool compose = false,
    String? workspaceDirectory,
    Progress? pr,
  }) {
    String limitFlag = '';
    if (limit != 0) limitFlag = '-n $limit';
    if (compose) {
      assert(
          workspaceDirectory != null,
          'workspaceDirectory must '
          'be defined');

      return dockerComposeRun(
        'logs',
        '$limitFlag $containerid',
        pr: pr,
        workspaceDirectory: workspaceDirectory,
      );
    }
    return dockerRun(
      'logs',
      '$limitFlag $containerid',
      pr: pr,
    );
  }

  /// Attaches to the running container and starts a bash command prompt.
  void cli() {
    dockerRun('exec', '-it $containerid /bin/bash', terminal: true);
  }

  @override
  String toString() => '$containerid ${image?.fullname} $status $name';
}

/// Describes a [Volume] and where it is to be mounted
/// in a container.
class VolumeMount {
  /// The volume to mount.
  Volume volume;

  /// The path within the container the volume is to be mounted into.
  String mountPath;

  /// Describes a [Volume] and where it is to be mounted
  /// in a container.
  VolumeMount(this.volume, this.mountPath);
}
