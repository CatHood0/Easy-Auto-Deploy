import 'package:auto_deployment/src/domain/entities/deployment_preferences.dart';
import 'package:auto_deployment/src/domain/entities/repository_selection.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/repo_provider_repository.dart';

part 'repository_event.dart';
part 'repository_state.dart';

class RepositoryBloc extends Bloc<RepositoryEvent, RepositoryState> {
  final RepoProviderRepository _repository;
  List<Repository> _repositories = [];

  RepositoryBloc(this._repository) : super(RepositoryInitial()) {
    on<LoadRepositories>(_onLoadRepositories);
    on<AddRepository>(_onAddRepository);
    on<UpdateRepository>(_onUpdateRepository);
    on<DeleteRepository>(_onDeleteRepository);
    on<SelectRepository>((
      SelectRepository event,
      Emitter<RepositoryState> emit,
    ) {
      emit(state.copyWith(
        selection: event.repository,
      ));
      DeploymentPreferences.getCachedDeploymentPreferences()
          .copyWith(lastSelectedRepository: event.repository.id)
          .saveToPref();
    });
  }

  Future<void> _onLoadRepositories(
    LoadRepositories event,
    Emitter<RepositoryState> emit,
  ) async {
    emit(RepositoryLoading(selection: state.selection));
    try {
      _repositories = await _repository.getAll();
      final Repository? selectedRepository = await _repository.getLastUsed();
      emit(RepositoryLoaded(
        repositories: List.from(_repositories),
        selection: selectedRepository,
      ));
    } catch (e) {
      emit(RepositoryError(
        message: e.toString(),
        selection: state.selection,
      ));
      rethrow;
    }
  }

  Future<void> _onAddRepository(
    AddRepository event,
    Emitter<RepositoryState> emit,
  ) async {
    emit(RepositoryLoading(selection: state.selection));
    try {
      final Repository newRepo = await _repository.insert(event.repository);
      _repositories.add(newRepo);
      final Repository? selectedRepository = await _repository.getLastUsed();
      emit(RepositoryLoaded(
        repositories: List.from(_repositories),
        selection: selectedRepository,
      ));
    } catch (e) {
      emit(
        RepositoryError(
          message: e.toString(),
          selection: state.selection,
        ),
      );
      rethrow;
    }
  }

  Future<void> _onUpdateRepository(
    UpdateRepository event,
    Emitter<RepositoryState> emit,
  ) async {
    emit(RepositoryLoading(selection: state.selection));
    try {
      await _repository.update(
        event.repository,
        event.deepUpdate,
      );
      final int index = _repositories.indexWhere(
        (Repository repo) => repo.id == event.repository.id,
      );
      if (index != -1) {
        _repositories[index] = event.repository;
      }
      final Repository? selectedRepository = await _repository.getLastUsed();
      emit(
        RepositoryLoaded(
          repositories: List.from(_repositories),
          selection: selectedRepository,
        ),
      );
    } catch (e) {
      emit(
        RepositoryError(
          message: e.toString(),
          selection: state.selection,
        ),
      );
      rethrow;
    }
  }

  Future<void> _onDeleteRepository(
    DeleteRepository event,
    Emitter<RepositoryState> emit,
  ) async {
    try {
      await _repository.delete(event.id);
      _repositories.removeWhere(
        (repo) => repo.id == event.id,
      );
      final DeploymentPreferences preferences =
          DeploymentPreferences.getCachedDeploymentPreferences();
      if (preferences.lastSelectedRepository != null &&
          event.id == preferences.lastSelectedRepository) {
        preferences.copyWith(lastSelectedRepository: null).saveToPref();
      }

      final Repository? selectedRepository = await _repository.getLastUsed();
      emit(
        RepositoryLoaded(
          repositories: List.from(_repositories),
          selection: selectedRepository,
        ),
      );
    } catch (e) {
      emit(
        RepositoryError(
          message: e.toString(),
          selection: state.selection,
        ),
      );
      rethrow;
    }
  }

  RepoProviderRepository get provider => _repository;
}
