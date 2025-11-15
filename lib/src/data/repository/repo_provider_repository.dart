import 'package:auto_deployment/src/domain/entities/deployment_preferences.dart';
import 'package:auto_deployment/src/domain/entities/repository_arguments.dart';
import 'package:auto_deployment/src/domain/entities/repository_selection.dart';
import 'package:auto_deployment/src/domain/repository/repo_provider_repository.dart';

import '../services/db/database_provider.dart';

class RepoProviderRepositoryImpl extends RepoProviderRepository {
  static final DeploymentProvider _provider = DeploymentProvider.instance;

  static const String _table = 'repositories';
  static const String _argTable = 'arguments';
  static const String _environmentTable = 'environment';

  @override
  Future<List<RepositoryArguments>> getArgumentsFromRepo(int id) async {
    // by some limitations, we cannot use joins at this point...
    final List<Map<String, Object?>> result = await _provider.query(
      'SELECT * FROM $_argTable WHERE repo_id = ?',
      args: [id],
    );
    final List<RepositoryArguments> args = <RepositoryArguments>[];
    for (Map<String, Object?> arg in result) {
      final List<Map<String, Object?>> environments = await _provider.query(
        'SELECT * FROM $_environmentTable WHERE repo_id = ?',
        args: [id],
      );
      args.add(
        RepositoryArguments.fromMap(arg).copyWith(
          environmentVars: environments
              .map(
                EnvironmentVar.fromMap,
              )
              .toList(),
        ),
      );
    }
    return <RepositoryArguments>[...args];
  }

  @override
  Future<List<Repository>> getAll() async {
    final List<Map<String, Object?>> result = await _provider.query(
      'SELECT * FROM $_table',
    );

    final List<Repository> repositories = <Repository>[];
    for (var repo in result) {
      repositories.add(
        Repository.fromMap(repo).copyWith(
          instructions: await getArgumentsFromRepo(repo['id'] as int),
        ),
      );
    }

    return <Repository>[...repositories];
  }

  @override
  Future<Repository?> getLastUsed() async {
    final int? lastUsed = DeploymentPreferences.getCachedDeploymentPreferences()
        .lastSelectedRepository;
    if (lastUsed == null) {
      final List<Map<String, Object?>> result = (await _provider
          .query('SELECT * FROM $_table ORDER BY id DESC LIMIT 1'));
      if (result.isEmpty) return null;
      final Repository repo = Repository.fromMap(result.single).copyWith(
        instructions: await getArgumentsFromRepo(
          result.single['id'] as int,
        ),
      );

      DeploymentPreferences.getCachedDeploymentPreferences()
          .copyWith(lastSelectedRepository: repo.id)
          .saveToPref();
      return repo;
    }
    return await queryRepo(lastUsed);
  }

  @override
  Future<Repository?> queryRepo(Object id) async {
    final List<Map<String, Object?>> result = (await _provider.query(
      'SELECT * FROM $_table WHERE id = ? LIMIT 1',
      args: [id],
    ));
    if (result.isEmpty) return null;
    return Repository.fromMap(result.single).copyWith(
      instructions: await getArgumentsFromRepo(
        result.single['id'] as int,
      ),
    );
  }

  @override
  Future<bool> update(
    Repository repo, [
    bool deepUpdate = true,
  ]) async {
    final bool updatedRepo = await _provider.update(
      _table,
      values: repo.toMap(),
      args: <Object>[repo.id],
    );
    // so..., we need to found a way to make this more
    // easy to read
    if (deepUpdate) {
      for (RepositoryArguments ins in repo.instructions) {
        await _provider.update(
          _argTable,
          values: ins.toMap(),
          args: <Object>[ins.id],
        );
        for (EnvironmentVar envVar in ins.environmentVars) {
          await _provider.update(
            _environmentTable,
            values: envVar.toMap(),
            args: <Object>[envVar.id],
          );
        }
      }
    }

    return updatedRepo;
  }

  @override
  Future<Repository> insert(Repository selection) async {
    //TODO: insert args too

    final int inserted = await _provider.insert(
      _table,
      values: selection.toMap(),
    );
    Repository copy = selection.copyWith(id: inserted);
    // so..., we need to found a way to make this more
    // easy to read
    int index = 0;
    int envIndex = 0;
    for (RepositoryArguments ins in copy.instructions) {
      index;
      final int id = await _provider.insert(
        _argTable,
        values: ins.copyWith(repoId: copy.id).toMap(),
      );
      copy = copy..instructions[index] = ins.copyWith(id: id, repoId: copy.id);
      for (EnvironmentVar envVar in ins.environmentVars) {
        final int envId = await _provider.insert(
          _environmentTable,
          values: envVar.copyWith(repoId: copy.id).toMap(),
        );
        copy = copy
          ..instructions[index].environmentVars[envIndex] =
              envVar.copyWith(id: envId, repoId: copy.id);
        envIndex++;
      }
      envIndex = 0;
      index++;
    }
    return copy;
  }

  @override
  Future<bool> delete(Object id) {
    return _provider.delete(_table, args: <Object?>[id]);
  }
}
