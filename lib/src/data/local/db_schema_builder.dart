/// Defines the possible SQL data types for a column.
enum SqlType {
  INTEGER,
  TEXT,
  REAL,
  VARCHAR,
  BLOB,
  unknown,
}

enum Operation {
  CREATE,
  ALTER,
  INSERT,
}

enum AlterScope {
  COLUMN,
  CONSTRAINT,
  TABLE,
}

/// Represents a database table.
class Table {
  /// The name of the table.
  final String name;

  /// The list of columns in the table.
  final List<Column> columns;

  /// The list of foreign keys in the table.
  final List<ForeignKey> foreignKeys;

  /// {
  ///  "op": Operation.ALTER,
  ///  "apply": "ADD",
  ///  "apply_level": AlterScope.CONSTRAINT // column, table, constraint
  ///  "constrains": "<name>"
  ///  "end_suffix": "some extra args",
  /// }
  ///
  /// {
  ///  "op": Operation.ALTER,
  ///  "apply_op": "ALTER",
  ///  "apply_level": AlterScope.COLUMN, // column, table, constraint
  ///  "constraints": "",
  ///  "end_suffix": "DROP DEFAULT", // adds any argument that you want at the end
  /// }
  final Map<String, dynamic> args;

  final int? values;

  /// Creates a new table definition.
  Table(
    this.name, {
    Map<String, dynamic>? args,
    required this.columns,
    this.values,
    this.foreignKeys = const <ForeignKey>[],
  }) : args = args ??
            <String, dynamic>{
              "op": Operation.CREATE,
              "apply_op": '',
              "apply_level": AlterScope.TABLE,
              "constraints": "",
              "end_suffix": '',
            };

  /// Creates a new table definition.
  Table.insert(
    this.name, {
    required this.columns,
    required this.values,
  })  : foreignKeys = <ForeignKey>[],
        args = <String, dynamic>{
          "op": Operation.INSERT,
          "apply_op": 'VALUES (',
          "apply_level": AlterScope.TABLE,
          "constraints": "",
          "end_suffix": ')',
        };

  Table.renameTable(
    this.name, {
    required String typeChange,
    required String newName,
  })  : values = null,
        columns = [],
        foreignKeys = <ForeignKey>[],
        args = <String, dynamic>{
          "op": Operation.ALTER,
          "apply_op": typeChange,
          "apply_level": AlterScope.TABLE,
          "constraints": "",
          "end_suffix": newName,
        };

  Table.renameColumn(
    this.name, {
    required String oldName,
    required String newName,
  })  : values = null,
        columns = [
          Column(oldName, SqlType.unknown),
          Column(newName, SqlType.unknown),
        ],
        foreignKeys = <ForeignKey>[],
        args = <String, dynamic>{
          "op": Operation.ALTER,
          "apply_op": "RENAME",
          "apply_level": AlterScope.COLUMN,
          "constraints": "",
          "end_suffix": "",
        };

  Table.modifyColumn(
    this.name, {
    required Column column,
    String constraints = "",
    String suffix = "",
  })  : values = null,
        columns = [column],
        foreignKeys = <ForeignKey>[],
        args = <String, dynamic>{
          "op": Operation.ALTER,
          "apply_op": "MODIFY",
          "apply_level": AlterScope.COLUMN,
          "constraints": constraints,
          "end_suffix": suffix,
        };

  Table.addColumn(
    this.name, {
    required Column column,
    String constraints = "",
    String suffix = "",
  })  : values = null,
        columns = [column],
        foreignKeys = <ForeignKey>[],
        args = <String, dynamic>{
          "op": Operation.ALTER,
          "apply_op": "ADD",
          "apply_level": AlterScope.COLUMN,
          "constraints": constraints,
          "end_suffix": suffix,
        };

  Table.dropColumn(
    this.name, {
    required String columnName,
  })  : values = null,
        columns = [Column.unknown(columnName)],
        foreignKeys = <ForeignKey>[],
        args = <String, dynamic>{
          "op": Operation.ALTER,
          "apply_op": "DROP",
          "apply_level": AlterScope.COLUMN,
          "constraints": "",
          "end_suffix": "",
        };

  bool get isCreate => args['op'] == Operation.CREATE;
  bool get isAlter => args['op'] == Operation.ALTER;
  bool get isInsert => args['op'] == Operation.INSERT;
  bool get isRename => (args['apply_op'] as String).toLowerCase().contains(
        'rename',
      );

  /// Converts the table definition to a `CREATE TABLE` SQL statement.
  String toQuery() {
    if (isAlter) {
      final String ops = (args['apply_op'] as String).toUpperCase();
      final StringBuffer buffer = StringBuffer(
        'ALTER TABLE $name $ops',
      );

      final AlterScope applyLevel = args['apply_level'] as AlterScope;

      switch (applyLevel) {
        case AlterScope.TABLE:
          if (isRename) {
            buffer.write(args['end_suffix'] as String);
            break;
          }
          buffer.write("TABLE ${args['end_suffix']}");
          break;
        case AlterScope.COLUMN:
          buffer.write("COLUMN ");
          break;
        case AlterScope.CONSTRAINT:
          buffer.write(
            "CONSTRAINT "
            "${args['constraint']} "
            "${args['end_suffix']}"
            "(${columns.single.name})",
          );
          break;
      }

      if (applyLevel == AlterScope.COLUMN) {
        if (isRename) {
          assert(
            columns.length == 2,
            'must have two columns to rename correctly',
          );
          buffer.write("${columns[0].name} TO ${columns[1].name}");
        }

        if (ops == 'ADD' || ops == 'MODIFY') {
          buffer.write(
            "${columns.single.name} "
            "${columns.single.typeSql()} "
            "${ops == 'ADD' ? '' : columns.single.constraints()} "
            "${args['constraints'] as String? ?? ''} "
            "${args['end_suffix'] as String? ?? ''}",
          );
        }
        if (ops == 'DROP') {
          buffer.write(columns.single.name);
        }
      }

      return '$buffer'.trim();
    }
    if (isInsert) {
      final String ops = (args['apply_op'] as String).toUpperCase();
      final StringBuffer buffer = StringBuffer(
        'INSERT INTO $name (',
      )
        ..write(columns.map((v) => v.name).join(','))
        ..write(") ")
        ..write(ops)
        ..write("(${List<String>.generate(
          values!,
          (int _) => "?",
        ).join(',')}"
            "${args['end_suffix'] as String}");

      return '$buffer'.trim();
    }
    final List<String> columnDefs = columns
        .map(
          (Column c) => c.toSql(),
        )
        .toList();
    final List<String> foreignKeyDefs = foreignKeys
        .map(
          (ForeignKey fk) => fk.toSql(),
        )
        .toList();

    return 'CREATE TABLE $name (\n  ${[
      ...columnDefs,
      ...foreignKeyDefs
    ].join(',\n  ')}\n)';
  }
}

/// Represents a column in a database table.
class Column {
  /// The name of the column.
  final String name;

  /// The data type of the column.
  final SqlType type;

  /// Whether this column is the primary key.
  final bool isPrimaryKey;

  /// Whether this column should auto-increment.
  final bool isAutoIncrement;

  /// Whether this column can be null.
  final bool isNullable;

  /// The length of the column if it is of type VARCHAR.
  final int? length;
  /// The length of the column if it is of type VARCHAR.

  final bool unique;

  /// Creates a new column definition.
  Column(
    this.name,
    this.type, {
    this.unique = false,
    this.isPrimaryKey = false,
    this.isAutoIncrement = false,
    this.isNullable = true,
    this.length,
  });

  Column.unknown(
    this.name, {
    this.isPrimaryKey = false,
    this.isAutoIncrement = false,
    this.isNullable = true,
    this.unique = false,
    this.length,
  }) : type = SqlType.unknown;

  String typeSql() {
    switch (type) {
      case SqlType.INTEGER:
        return 'INTEGER';
      case SqlType.TEXT:
        return 'TEXT';
      case SqlType.REAL:
        return 'REAL';
      case SqlType.VARCHAR:
        return 'VARCHAR(${length ?? 255})';
      case SqlType.BLOB:
        return 'BLOB';
      default:
        return '';
    }
  }

  String constraints() {
    final StringBuffer buffer = StringBuffer();
    if (isPrimaryKey) {
      buffer.write('PRIMARY KEY ');
      if (isAutoIncrement) {
        buffer.write('AUTOINCREMENT ');
      }
    }

    if (unique) {
      buffer.write('UNIQUE ');
    }

    if (!isNullable) {
      buffer.write('NOT NULL ');
    }
    return '$buffer'.trim();
  }

  /// Converts the column definition to its SQL representation.
  String toSql() => '$name ${typeSql()} ${constraints()}';
}

/// Represents a foreign key constraint in a database table.
class ForeignKey {
  /// The name of the local column.
  final String column;

  /// The name of the foreign table.
  final String to_table;

  /// The name of the foreign column.
  final String to_column;

  final String constraints;

  /// Creates a new foreign key definition.
  ForeignKey({
    required this.column,
    required this.to_table,
    required this.to_column,
    this.constraints = "",
  });

  /// Converts the foreign key definition to its SQL representation.
  String toSql() {
    return 'FOREIGN KEY ($column) REFERENCES $to_table($to_column)${constraints.isEmpty ? '' : ' $constraints'}';
  }
}
