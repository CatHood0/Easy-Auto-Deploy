part of 'repository_bloc.dart';

abstract class RepositoryState {
  final Repository? selection;

  RepositoryState({this.selection});

  RepositoryState copyWith({
    Repository? selection,
  });
}

class RepositoryInitial extends RepositoryState {
  RepositoryInitial({super.selection});

  @override
  RepositoryState copyWith({
    Repository? selection,
  }) {
    return RepositoryInitial(
      selection: selection ?? super.selection,
    );
  }
}

class RepositoryLoading extends RepositoryState {
  RepositoryLoading({required super.selection});
  @override
  RepositoryState copyWith({
    Repository? selection,
  }) {
    return RepositoryLoading(
      selection: selection ?? super.selection,
    );
  }
}

class RepositoryLoaded extends RepositoryState {
  final List<Repository> repositories;

  RepositoryLoaded({
    required super.selection,
    required this.repositories,
  });

  @override
  RepositoryState copyWith({
    Repository? selection,
    List<Repository>? repositories,
  }) {
    return RepositoryLoaded(
      selection: selection ?? super.selection,
      repositories: repositories ?? this.repositories,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! RepositoryLoaded) return false;
    return _listEquality.equals(
          repositories,
          other.repositories,
        ) &&
        selection == other.selection;
  }

  @override
  int get hashCode => Object.hash(
        repositories.hashCode,
        selection.hashCode,
      );
}

class RepositoryError extends RepositoryState {
  final String message;

  RepositoryError({
    required super.selection,
    required this.message,
  });

  @override
  RepositoryState copyWith({
    Repository? selection,
    String? message,
  }) {
    return RepositoryError(
      selection: selection ?? super.selection,
      message: message ?? this.message,
    );
  }
}

final ListEquality<Repository> _listEquality = ListEquality();
