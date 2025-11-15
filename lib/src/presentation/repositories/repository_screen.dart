import 'package:auto_deployment/src/presentation/bloc/repository_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import 'common/repository_button.dart';
import 'common/repository_card.dart';

class RepositoriesScreen extends StatelessWidget {
  const RepositoriesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Repositorios'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: RepositoriesContent(),
      ),
    );
  }
}

class RepositoriesContent extends StatelessWidget {
  const RepositoriesContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepositoryBloc, RepositoryState>(builder: (
      BuildContext context,
      RepositoryState state,
    ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RepositoriesHeader(),
          const SizedBox(height: 24),
          Flexible(
            child: RepositoryList(),
          ),
          AddRepositoryButton(),
        ],
      );
    });
  }
}

class RepositoriesHeader extends StatelessWidget {
  const RepositoriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repositorios Configurados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'JetBrains Mono NF',
            fontFamilyFallback: ['Monospace', 'Consolas'],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gestiona los repositorios disponibles para despliegue automático',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'JetBrains Mono NF',
            fontFamilyFallback: ['Monospace', 'Consolas'],
          ),
        ),
      ],
    );
  }
}

class RepositoryList extends StatefulWidget {
  const RepositoryList({
    super.key,
  });

  @override
  State<RepositoryList> createState() => _RepositoryListState();
}

class _RepositoryListState extends State<RepositoryList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepositoryBloc, RepositoryState>(
      builder: (
        BuildContext context,
        RepositoryState state,
      ) {
        if (state is RepositoryLoading || state is RepositoryInitial) {
          return Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        if (state is RepositoryError) {
          return Center(
            child: Column(
              children: [
                Text(
                  'No se pudo cargar correctamente los repositorios',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'JetBrains Mono NF',
                    fontFamilyFallback: ['Monospace', 'Consolas'],
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox()
              ],
            ),
          );
        }
        final List<Repository> data = (state as RepositoryLoaded).repositories;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (BuildContext ctx, int index) {
            final Repository repo = data.elementAt(index);
            return RepositoryCard(repository: repo);
          },
        );
      },
    );
  }
}
