import 'package:auto_deployment/src/presentation/bloc/repository_bloc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/entities.dart';

class RepositorySelectorWidget extends StatefulWidget {
  const RepositorySelectorWidget({super.key});

  @override
  State<RepositorySelectorWidget> createState() =>
      _RepositorySelectorWidgetState();
}

class _RepositorySelectorWidgetState extends State<RepositorySelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepositoryBloc, RepositoryState>(builder: (
      BuildContext context,
      RepositoryState state,
    ) {
      Repository? selectedRepo;
      final List<Repository> repositories = <Repository>[];

      if (state is RepositoryLoaded) {
        repositories.addAll(state.repositories);
        selectedRepo = state.selection;
      }

      return DropdownButtonHideUnderline(
        child: DropdownButton2<Repository>(
          value: selectedRepo,
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            offset: Offset(0, -5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          hint: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            child: state is RepositoryLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator.adaptive(),
                      const SizedBox(width: 5),
                      const Text('Loading repositories'),
                    ],
                  )
                : const Text('Select a repository'),
          ),
          isExpanded: true,
          onChanged: (Repository? newValue) {
            if (newValue == null) return;
            selectedRepo = newValue;
            context.read<RepositoryBloc>().add(
                  SelectRepository(
                    repository: newValue,
                  ),
                );
          },
          items: repositories.map<DropdownMenuItem<Repository>>((
            Repository repo,
          ) {
            return DropdownMenuItem<Repository>(
              value: repo,
              child: RepositorymenuItemWidget(repo: repo),
            );
          }).toList(),
        ),
      );
    });
  }
}

class RepositorymenuItemWidget extends StatelessWidget {
  final Repository repo;
  const RepositorymenuItemWidget({
    super.key,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '[${repo.branch}]',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.lightBlueAccent,
              ),
              overflow: TextOverflow.clip,
              maxLines: 1,
            ),
            const SizedBox(width: 3),
            Text(
              repo.repoImageName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.clip,
              maxLines: 1,
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          repo.repo,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xBBFFFFFF),
          ),
          overflow: TextOverflow.clip,
          maxLines: 1,
        ),
      ],
    );
  }
}
