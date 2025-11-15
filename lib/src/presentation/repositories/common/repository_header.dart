import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/repository_selection.dart';
import '../../bloc/repository_bloc.dart';
import '../widgets/repository_details_dialog.dart';

class RepositoryHeader extends StatelessWidget {
  const RepositoryHeader({
    super.key,
    required this.repository,
  });

  final Repository repository;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.storage_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            repository.repoImageName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'JetBrains Mono NF',
              fontFamilyFallback: ['Monospace', 'Consolas'],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_rounded, size: 18),
          onPressed: () {
            _showRepositoryDialog(
              context,
              repository,
            );
          },
        ),
      ],
    );
  }

  void _showRepositoryDialog(
    BuildContext context,
    Repository repo,
  ) {
    showDialog(
      context: context,
      builder: (context) => RepositoryEditDialog(
        isInsertion: false,
        provider: context.watch<RepositoryBloc>().provider,
        selection: repo,
      ),
    );
  }
}
