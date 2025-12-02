import '../../docker2.dart';
import 'exceptions.dart';

/// Holds a list of Docker containers.
class ComposeVolumes extends Volumes {
  static final ComposeVolumes _self = ComposeVolumes();

  /// Factory ctor
  factory ComposeVolumes() => _self;

  /// returns a list of containers.
  @override
  List<Volume> volumes() {
    final List<Volume> volumeCache = <Volume>[];

    const String args =
        '''--format "table {{.Name}}|{{.Driver}}|{{.Mountpoint}}|{{.Labels}}|{{.Scope}}"''';

    final List<String> lines = dockerRun('volumes', args)
        // remove the heading.
        .toList()
      ..removeAt(0);

    for (final String line in lines) {
      final List<String> parts = line.split('|');
      final String name = parts[0];
      final String driver = parts[1];
      final String mountpoint = parts[2];
      final String labels = parts[3];
      final String scope = parts[4];

      final Volume container = Volume(
        name: name,
        driver: driver,
        mountpoint: mountpoint,
        labels: _splitLabels(labels),
        scope: scope,
      );
      volumeCache.add(container);
      //}
    }
    return volumeCache;
  }

  List<VolumeLabel> _splitLabels(String labelPairs) {
    final List<VolumeLabel> labels = <VolumeLabel>[];

    if (labelPairs.trim().isEmpty) {
      return labels;
    }
    final List<String> parts = labelPairs.split(',');

    for (final String label in parts) {
      final List<String> pair = label.split('=');
      if (pair.length != 2) {
        throw InvalidVolumeLabelException(label);
      }
      labels.add(VolumeLabel(pair[0], pair[1]));
    }
    return labels;
  }
}
