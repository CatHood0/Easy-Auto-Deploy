/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

import '../../docker2.dart';

///
/// Builds a docker image from [pathToDockerFile] and tags it as
/// [repository]/[imageName]:[version] (repository optional).
///
/// Set [clean] to true to add `--no-cache`.
/// Set [pull] to true to add `--pull`.
/// Provide extra [buildArgs] like `['KEY=VALUE', 'FOO=BAR']`.
/// If [buildx] is true we invoke `docker buildx build`,
///   otherwise `docker build`.
/// Throws [DockerBuildException] on any non-zero exit.
/// If passed, the [workingDirectory] is used when running the
/// docker build command. This is important as it affects what
/// files the docker build command will add to its context.
/// If not passed then the current working directory will be used.
///
/// Pass [showProgress] == false to only show errors.
Image build({
  required String pathToDockerFile,
  required String imageName,
  required String version,
  bool clean = false,
  bool pull = false,
  List<String> buildArgs = const <String>[],
  String? repository,
  String? workingDirectory,
  bool showProgress = true,
  bool buildx = false,
}) {
  final String cleanArg = clean ? ' --no-cache' : '';
  final String pullArg = pull ? ' --pull' : '';

  workingDirectory ??= pwd;

  final String tag = tagName(
    repository: repository,
    imageName: imageName,
    version: version,
  );

  final StringBuffer buildArgList = StringBuffer();
  if (buildArgs.isNotEmpty) {
    for (final String arg in buildArgs) {
      buildArgList.write('--build-arg $arg ');
    }
  }

  // When showProgress==true we show stdout+stderr; otherwise only stderr.
  final Progress progressSink =
      showProgress ? Progress.print() : Progress.printStdErr();

  // Use a single command string; for buildx we emit "buildx build".
  final String builder = buildx ? 'buildx build' : 'build';

  final String cmd = 'docker $builder'
      '$pullArg '
      '$buildArgList '
      '$cleanArg '
      '-t $tag -f $pathToDockerFile .';

  final Progress progress = cmd.start(
      workingDirectory: workingDirectory,
      nothrow: true, // we want to check exit code ourselves
      progress: progressSink);

  final int? code = progress.exitCode;
  if (code != 0) {
    throw DockerBuildException(
      'Docker $builder failed (exit $code). Command:\n$cmd',
      exitCode: code,
    );
  }

  return Image.fromName(tag);
}

Image buildx({
  required String pathToDockerFile,
  required String imageName,
  required String version,
  bool clean = false,
  bool pull = false,
  List<String> buildArgs = const <String>[],
  String? repository,
  String? workingDirectory,
  bool showProgress = true,
}) =>
    build(
        pathToDockerFile: pathToDockerFile,
        imageName: imageName,
        version: version,
        clean: clean,
        pull: pull,
        buildArgs: buildArgs,
        repository: repository,
        workingDirectory: workingDirectory,
        showProgress: showProgress,
        buildx: true);

/// Publishes the image to the repository defined in [image].
/// Throws [DockerPushException] on any non-zero exit.
void publish({required Image image, bool showProgress = true}) {
  final Progress progressSink =
      showProgress ? Progress.print() : Progress.printStdErr();
  final String cmd = 'docker push ${image.fullname}';
  final Progress progress = cmd.start(nothrow: true, progress: progressSink);
  final int? code = progress.exitCode;
  if (code != 0) {
    throw DockerPushException(
      'Docker push failed (exit $code). Command:\n$cmd',
      exitCode: code,
    );
  }
}

String tagName(
        {required String imageName,
        required String version,
        String? repository}) =>
    repository != null
        ? '$repository/$imageName:$version'
        : '$imageName:$version';

String tagNameLatest({required String imageName, String? repository}) =>
    repository != null ? '$repository/$imageName:latest' : '$imageName:latest';

/// Thrown when a docker build (build or buildx) fails.
class DockerBuildException implements Exception {
  final String message;

  final int? exitCode;

  DockerBuildException(this.message, {this.exitCode});

  @override
  String toString() => 'DockerBuildException(exitCode=$exitCode): $message';
}

/// Thrown when a docker push fails.
class DockerPushException implements Exception {
  final String message;

  final int? exitCode;

  DockerPushException(this.message, {this.exitCode});

  @override
  String toString() => 'DockerPushException(exitCode=$exitCode): $message';
}
