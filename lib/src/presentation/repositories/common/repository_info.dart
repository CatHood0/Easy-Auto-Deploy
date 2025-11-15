import 'package:flutter/material.dart';

import '../../../domain/entities/entities.dart';

class RepositoryInfo extends StatelessWidget {
  const RepositoryInfo({
    super.key,
    required this.repository,
  });

  final Repository repository;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoRow(label: 'Repositorio', value: repository.repo),
        InfoRow(
          label: 'Rama',
          value: repository.branch,
          color: Colors.lightBlueAccent,
        ),
        InfoRow(
          label: 'Require autenticación',
          value: repository.requireAuth ? 'Sí' : 'No',
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Flexible(
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                fontFamily: 'JetBrains Mono NF',
                fontFamilyFallback: ['Monospace', 'Consolas'],
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontFamily: 'JetBrains Mono NF',
                fontFamilyFallback: ['Monospace', 'Consolas'],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
