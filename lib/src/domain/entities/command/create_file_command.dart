import 'command_base.dart';

class CreateFileCommand extends CommandBase {
  final String filePath;
  final String content;

  CreateFileCommand({
    required this.filePath,
    required this.content,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'create_file',
      'filePath': filePath,
      'content': content,
    };
  }

  factory CreateFileCommand.fromJson(Map<String, dynamic> map) {
    return CreateFileCommand(
      filePath: map['filePath'] as String,
      content: map['content'] as String,
    );
  }

  CreateFileCommand copyWith({
    String? filePath,
    String? content,
  }) {
    return CreateFileCommand(
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateFileCommand &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath &&
          content == other.content;

  @override
  int get hashCode => filePath.hashCode ^ content.hashCode;
}
