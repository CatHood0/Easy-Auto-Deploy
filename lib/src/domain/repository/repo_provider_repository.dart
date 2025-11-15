import 'package:auto_deployment/src/domain/entities/repository_arguments.dart';
import 'package:auto_deployment/src/domain/entities/repository_selection.dart';

abstract class RepoProviderRepository {
  /// Returns all the repositories into [available_repositories] table
  Future<List<Repository>> getAll();
  Future<List<RepositoryArguments>> getArgumentsFromRepo(int id);
  Future<Repository?> getLastUsed();
  Future<Repository?> queryRepo(Object id);
  Future<Repository> insert(Repository selection);
  Future<bool> delete(Object id);
  Future<bool> update(
    Repository repo, [
    bool deepUpdate = true,
  ]);
}
