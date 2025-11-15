import 'command_base.dart';

class RenameFileCommand extends CommandBase {
  final String oldPath;
  final String newPath;

  RenameFileCommand({
    required this.oldPath,
    required this.newPath,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'rename_file',
      'oldPath': oldPath,
      'newPath': newPath,
    };
  }

  factory RenameFileCommand.fromJson(Map<String, dynamic> map) {
    return RenameFileCommand(
      oldPath: map['oldPath'] as String,
      newPath: map['newPath'] as String,
    );
  }

  RenameFileCommand copyWith({
    String? oldPath,
    String? newPath,
  }) {
    return RenameFileCommand(
      oldPath: oldPath ?? this.oldPath,
      newPath: newPath ?? this.newPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RenameFileCommand &&
          runtimeType == other.runtimeType &&
          oldPath == other.oldPath &&
          newPath == other.newPath;

  @override
  int get hashCode => oldPath.hashCode ^ newPath.hashCode;
}