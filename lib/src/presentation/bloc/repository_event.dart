part of 'repository_bloc.dart';

abstract class RepositoryEvent {}

class LoadRepositories extends RepositoryEvent {}

class AddRepository extends RepositoryEvent {
  final Repository repository;

  AddRepository(this.repository);
}

class SelectRepository extends RepositoryEvent {
  final Repository repository;

  SelectRepository({
    required this.repository,
  });
}

class UpdateRepository extends RepositoryEvent {
  final Repository repository;
  final bool deepUpdate;

  UpdateRepository(
    this.repository,
    this.deepUpdate,
  );
}

class DeleteRepository extends RepositoryEvent {
  final int id;

  DeleteRepository(this.id);
}
