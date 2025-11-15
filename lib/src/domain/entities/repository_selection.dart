import 'package:flutter/foundation.dart';

import 'package:auto_deployment/src/domain/entities/repository_arguments.dart';

class Repository {
  final int id;
  final String repo;
  final String branch;
  final String repoImageName;
  final bool requireAuth;
  final List<RepositoryArguments> instructions;
  final String? lastArgumentSelected;
  final DateTime updatedAt;

  const Repository({
    required this.id,
    required this.repo,
    required this.branch,
    required this.requireAuth,
    required this.repoImageName,
    required this.instructions,
    required this.updatedAt,
    required this.lastArgumentSelected,
  });

  Repository copyWith({
    int? id,
    String? repo,
    String? branch,
    String? repoImageName,
    String? lastArgumentSelected,
    bool? requireAuth,
    List<RepositoryArguments>? instructions,
    DateTime? updatedAt,
  }) {
    return Repository(
      id: id ?? this.id,
      repo: repo ?? this.repo,
      branch: branch ?? this.branch,
      requireAuth: requireAuth ?? this.requireAuth,
      repoImageName: repoImageName ?? this.repoImageName,
      instructions: instructions ?? this.instructions,
      updatedAt: updatedAt ?? this.updatedAt,
      lastArgumentSelected: lastArgumentSelected ?? this.lastArgumentSelected,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'repo': repo,
      'branch': branch,
      'require_auth': requireAuth ? 1 : 0,
      'image_name': repoImageName,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'last_arg_selected': lastArgumentSelected,
    };
  }

  factory Repository.fromMap(Map<String, dynamic> map) {
    return Repository(
      id: map['id']?.toInt() ?? -1,
      repo: map['repo'] ?? '',
      branch: map['branch'] ?? '',
      requireAuth: map['require_auth'] == 1 ? true : false,
      repoImageName: map['image_name'],
      lastArgumentSelected: map['last_arg_selected'],
      instructions: <RepositoryArguments>[],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] as int,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Repository &&
        other.id == id &&
        other.repo == repo &&
        other.branch == branch &&
        other.repoImageName == repoImageName &&
        other.updatedAt == updatedAt &&
        other.requireAuth == requireAuth &&
        other.lastArgumentSelected == lastArgumentSelected &&
        listEquals(other.instructions, instructions);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        repo.hashCode ^
        branch.hashCode ^
        updatedAt.hashCode ^
        requireAuth.hashCode ^
        repoImageName.hashCode ^
        lastArgumentSelected.hashCode ^
        instructions.hashCode;
  }
}
