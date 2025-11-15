import 'package:auto_deployment/src/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/repository_bloc.dart';
import '../../deployment/common/modern/gradient_buttons.dart';
import '../screens/details/repository_details_screen.dart';
import '../widgets/repository_details_dialog.dart';

class RepositoryActions extends StatelessWidget {
  final Repository repo;
  const RepositoryActions({
    super.key,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Hero(
            tag: 'repository-details-${repo.id}',
            child: GradientActionButton(
              icon: Icons.edit_note_rounded,
              label: 'Detalles',
              enabled: true,
              onPressed: () => _navigateToDetails(context),
              enabledGradient: const LinearGradient(
                colors: [
                  Color(0xFF66BB6A),
                  Color(0xFF4CAF50),
                ],
              ),
              width: double.infinity,
              height: 40,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GradientActionButton(
          icon: Icons.delete_rounded,
          label: 'Eliminar',
          enabled: true,
          onPressed: () {
            context.read<RepositoryBloc>().add(
                  DeleteRepository(
                    repo.id,
                  ),
                );
          },
          enabledGradient: const LinearGradient(
            colors: [Color(0xFFEF5350), Color(0xFFF44336)],
          ),
          width: 80,
          height: 40,
        ),
      ],
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepositoryDetailsScreen(
          repository: repo,
        ),
      ),
    );
  }
}

class AddRepositoryButton extends StatelessWidget {
  const AddRepositoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientActionButton(
      icon: Icons.add_rounded,
      label: 'Agregar Repositorio',
      enabled: true,
      onPressed: () => _showAddRepositoryDialog(context),
      enabledGradient: const LinearGradient(
        colors: [
          Color(0xFF2196F3),
          Color(0xFF03A9F4),
        ],
      ),
    );
  }

  void _showAddRepositoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RepositoryEditDialog(
        isInsertion: true,
        provider: context.read<RepositoryBloc>().provider,
      ),
    );
  }
}
