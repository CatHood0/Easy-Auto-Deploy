/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'docker.dart';
import 'exceptions.dart';
import 'volume.dart';

/// Holds a list of Docker containers.
class Volumes {
  static final Volumes _self = Volumes._internal();

  /// Factory ctor
  factory Volumes() => _self;

  Volumes._internal();

  /// returns a list of containers.
  List<Volume> volumes() {
    final List<Volume> volumeCache = <Volume>[];

    const String args =
        '''ls --format "table {{.Name}}|{{.Driver}}|{{.Mountpoint}}|{{.Labels}}|{{.Scope}}"''';

    final List<String> lines = dockerRun('volume', args)
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

  /// Finds and returns the volume with given name.
  /// Returns null if the volume doesn't exist.
  Volume? findByName(String name) {
    final List<Volume> list = volumes();

    for (final Volume volume in list) {
      if (name == volume.name) {
        return volume;
      }
    }
    return null;
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

/// A volume label containing the key and value
class VolumeLabel {
  /// The key
  String key;

  /// The value
  String value;

  /// A volume label containing the key and value
  VolumeLabel(this.key, this.value);
}
