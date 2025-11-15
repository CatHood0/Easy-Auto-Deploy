import 'dart:convert';

import 'package:collection/collection.dart';

import 'command/command_base.dart';

class RepositoryArguments {
  final int id;
  final int repoId;
  final String identifier;
  final List<EnvironmentVar> environmentVars;
  final List<CommandBase> steps;
  final bool requestForSudo;

  RepositoryArguments({
    required this.id,
    required this.repoId,
    required this.identifier,
    required this.steps,
    required this.environmentVars,
    this.requestForSudo = true,
  });

  RepositoryArguments copyWith({
    int? id,
    int? repoId,
    String? identifier,
    List<EnvironmentVar>? environmentVars,
    List<CommandBase>? steps,
    bool? requestForSudo,
  }) {
    return RepositoryArguments(
      id: id ?? this.id,
      repoId: repoId ?? this.repoId,
      identifier: identifier ?? this.identifier,
      steps: steps ?? this.steps,
      environmentVars: environmentVars ?? this.environmentVars,
      requestForSudo: requestForSudo ?? this.requestForSudo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'repo_id': repoId,
      'identifier': identifier,
      'commands': json.encode(
        steps
            .map(
              (CommandBase x) => x.toJson(),
            )
            .toList(),
      ),
      'request_sudo': requestForSudo ? 1 : 0,
    };
  }

  factory RepositoryArguments.fromMap(Map<String, dynamic> map) {
    return RepositoryArguments(
      id: map['id']?.toInt() ?? -1,
      repoId: map['repo_id'] ?? -1,
      identifier: map['identifier'] ?? '',
      environmentVars: [],
      steps: List<CommandBase>.from(
        (json.decode(map['commands'] as String) as List<dynamic>).map(
          (dynamic x) => CommandBase.fromJson(
            x,
          ),
        ),
      ),
      requestForSudo: map['request_sudo'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory RepositoryArguments.fromJson(String source) =>
      RepositoryArguments.fromMap(json.decode(source));
  @override
  String toString() {
      return 'Arguments('
          'id: $id, '
          'repoId: $repoId, '
          'environmentVars: $environmentVars, '
          'commands: $steps, '
          'request_sudo: request_sudo, '
          ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    const DeepCollectionEquality deepCollectionEquality =
        DeepCollectionEquality();
    return other is RepositoryArguments &&
        other.id == id &&
        other.repoId == repoId &&
        other.identifier == identifier &&
        deepCollectionEquality.equals(other.steps, steps) &&
        deepCollectionEquality.equals(other.environmentVars, environmentVars) &&
        other.requestForSudo == requestForSudo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        identifier.hashCode ^
        steps.hashCode ^
        environmentVars.hashCode ^
        requestForSudo.hashCode;
  }
}

class EnvironmentVar {
  final int id;
  final int repoId;
  final String key;
  final String value;

  EnvironmentVar({
    required this.id,
    required this.repoId,
    required this.key,
    required this.value,
  });

  EnvironmentVar copyWith({
    int? id,
    int? repoId,
    String? key,
    String? value,
  }) {
    return EnvironmentVar(
      id: id ?? this.id,
      repoId: repoId ?? this.repoId,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'repo_id': repoId,
      'key': key,
      'value': value,
    };
  }

  factory EnvironmentVar.fromMap(Map<String, dynamic> map) {
    return EnvironmentVar(
      id: map['id']?.toInt() ?? -1,
      repoId: map['repo_id'] ?? -1,
      key: map['key'] ?? '',
      value: map['value'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory EnvironmentVar.fromJson(String source) =>
      EnvironmentVar.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Arguments('
        'id: $id, '
        'repoId: $repoId, '
        'key: $key, '
        'value: $value, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EnvironmentVar &&
        other.key == key &&
        other.id == id &&
        other.repoId == repoId &&
        other.value == value;
  }

  @override
  int get hashCode =>
      key.hashCode ^ value.hashCode ^ id.hashCode ^ repoId.hashCode;
}
