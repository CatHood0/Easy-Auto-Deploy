import 'create_file_command.dart';
import 'move_file_command.dart';
import 'rename_file_command.dart';
import 'update_file_content_command.dart';

abstract class CommandBase {
  const CommandBase();

  Map<String, dynamic> toJson();

  T map<T>({
    required T Function(CreateFileCommand) createFile,
    required T Function(MoveFileCommand) moveFile,
    required T Function(RenameFileCommand) renameFile,
    required T Function(UpdateFileContentCommand) updateFileContent,
  }) {
    if (this is CreateFileCommand) {
      return createFile(this as CreateFileCommand);
    } else if (this is MoveFileCommand) {
      return moveFile(this as MoveFileCommand);
    } else if (this is RenameFileCommand) {
      return renameFile(this as RenameFileCommand);
    } else if (this is UpdateFileContentCommand) {
      return updateFileContent(this as UpdateFileContentCommand);
    } else {
      throw Exception('Unknown command type: $runtimeType');
    }
  }

  factory CommandBase.fromJson(Map<String, dynamic> map) {
    final type = map['type'] as String;
    switch (type) {
      case 'create_file':
        return CreateFileCommand.fromJson(map);
      case 'move_file':
        return MoveFileCommand.fromJson(map);
      case 'rename_file':
        return RenameFileCommand.fromJson(map);
      case 'update_file_content':
        return UpdateFileContentCommand.fromJson(map);
      default:
        throw Exception('Unknown command type: $type');
    }
  }
}
