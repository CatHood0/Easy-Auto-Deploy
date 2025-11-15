import 'package:auto_deployment/src/presentation/repositories/common/repository_button.dart';
import 'package:auto_deployment/src/presentation/repositories/common/repository_header.dart';
import 'package:auto_deployment/src/presentation/repositories/common/repository_info.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/entities.dart';

class RepositoryCard extends StatelessWidget {
  const RepositoryCard({
    super.key,
    required this.repository,
  });

  final Repository repository;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepositoryHeader(repository: repository),
            const SizedBox(height: 12),
            RepositoryInfo(repository: repository),
            const SizedBox(height: 12),
            RepositoryActions(repo: repository),
          ],
        ),
      ),
    );
  }
}
