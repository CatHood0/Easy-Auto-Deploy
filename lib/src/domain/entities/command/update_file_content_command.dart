import 'command_base.dart';

class UpdateFileContentCommand extends CommandBase {
  final String filePath;
  final String matchExpression;

  // if value replacement match with a EnvironmentVar
  // the values is automatically replaced
  final String valueReplacement;

  UpdateFileContentCommand({
    required this.filePath,
    required this.matchExpression,
    required this.valueReplacement,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'update_file_content',
      'filePath': filePath,
      'matchExpression': matchExpression,
      'valueReplacement': valueReplacement,
    };
  }

  factory UpdateFileContentCommand.fromJson(Map<String, dynamic> map) {
    return UpdateFileContentCommand(
      filePath: map['filePath'] as String,
      matchExpression: map['matchExpression'] as String,
      valueReplacement: map['valueReplacement'] as String,
    );
  }

  UpdateFileContentCommand copyWith({
    String? filePath,
    String? matchExpression,
    String? valueReplacement,
  }) {
    return UpdateFileContentCommand(
      filePath: filePath ?? this.filePath,
      matchExpression: matchExpression ?? this.matchExpression,
      valueReplacement: valueReplacement ?? this.valueReplacement,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateFileContentCommand &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath &&
          matchExpression == other.matchExpression &&
          valueReplacement == other.valueReplacement;

  @override
  int get hashCode =>
      filePath.hashCode ^ matchExpression.hashCode ^ valueReplacement.hashCode;
}

