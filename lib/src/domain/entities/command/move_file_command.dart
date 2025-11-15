import 'command_base.dart';

class MoveFileCommand extends CommandBase {
  final String from;
  final String to;

  MoveFileCommand({
    required this.from,
    required this.to,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'move_file',
      'from': from,
      'to': to,
    };
  }

  factory MoveFileCommand.fromJson(Map<String, dynamic> map) {
    return MoveFileCommand(
      from: map['from'] as String,
      to: map['to'] as String,
    );
  }

  MoveFileCommand copyWith({
    String? from,
    String? to,
  }) {
    return MoveFileCommand(
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoveFileCommand &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => from.hashCode ^ to.hashCode;
}