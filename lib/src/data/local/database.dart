import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_package;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqf;
import '../constant.dart';
import 'db_schema_builder.dart';

class AutoDeployDatabase {
  static final AutoDeployDatabase _instance = AutoDeployDatabase._();
  @visibleForTesting
  static bool testingMode = false;
  Database? _db;

  /// All the default tables are passed here

  //TODO: should we use an encrypted version of the database?
  // it's just a thought about the security
  final List<Table> tables = <Table>[
    Table('repositories', columns: <Column>[
      Column(
        'id',
        SqlType.INTEGER,
        isAutoIncrement: true,
        isPrimaryKey: true,
      ),
      Column(
        'repo',
        SqlType.TEXT,
        isNullable: false,
      ),
      Column(
        'branch',
        SqlType.VARCHAR,
        length: 70,
        isNullable: false,
      ),
      Column(
        'require_auth', SqlType.INTEGER,
        // commonly the background color
        isNullable: false,
      ),
      Column(
        'image_name', SqlType.TEXT,
        // commonly the background color
        isNullable: false,
        unique: true,
      ),
      Column(
        'last_arg_selected', SqlType.VARCHAR,
        // commonly the background color
        length: 170,
        isNullable: true,
      ),
      Column(
        'updated_at', SqlType.INTEGER,
        // commonly the background color
        isNullable: false,
      ),
    ]),
    Table(
      'arguments',
      // repo_args -> repository
      foreignKeys: [
        ForeignKey(
          column: 'repo_id',
          to_table: 'repositories',
          to_column: 'id',
          constraints: 'ON DELETE CASCADE',
        ),
      ], 
      columns: <Column>[
        Column(
          'id',
          SqlType.INTEGER,
          isPrimaryKey: true,
          isAutoIncrement: true
        ),
        Column(
          'repo_id',
          SqlType.INTEGER,
        ),
        Column(
          'identifier',
          SqlType.VARCHAR,
          length: 170,
          isNullable: false,
        ),
        // since some commands are totally different between
        // them, just save it as a json serialized
        Column(
          'commands',
          SqlType.TEXT,
          isNullable: true,
        ),
        Column(
          'request_sudo', SqlType.INTEGER,
          // commonly the background color
          isNullable: false,
        ),
      ],
    ),
    Table(
      'environment',
      // environemnt -> repo_args -> repository
      foreignKeys: [
        ForeignKey(
          column: 'repo_id',
          to_table: 'repositories',
          to_column: 'id',
          constraints: 'ON DELETE CASCADE',
        ),
      ],
      columns: <Column>[
        Column(
          'id',
          SqlType.INTEGER,
          unique: true,
          isPrimaryKey: true,
          isAutoIncrement: true
        ),
        Column(
          'repo_id',
          SqlType.INTEGER,
        ),
        Column(
          'key',
          SqlType.VARCHAR,
          length: 255,
          isNullable: false,
        ),
        Column(
          'value',
          SqlType.TEXT,
          isNullable: false,
        ),
      ],
    ),
  ];

  /// Just all the table/column changes are provided
  /// to this list
  ///
  //so... Yeah, we just add the changes at that place to avoid having
  // too much code at this point
  late final Map<int, List<Table>> changes = <int, List<Table>>{};

  AutoDeployDatabase._();

  factory AutoDeployDatabase.instance() {
    return _instance..database();
  }

  /// Returns the database instance, initializing it if necessary.
  Future<Database> database() async => _db ??= await _initialize();

  /// Closes the database connection.
  Future<void> closeDatabase() async {
    await _db?.close();
  }

  /// Initializes the database.
  Future<Database> _initialize() async {
    //TODO: we need to add better support for windows
    // (i don't have mac, so, i cannot add support for it)
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqf.sqfliteFfiInit();
      final String dbPath = await sqf.databaseFactoryFfi.getDatabasesPath();
      final String path =
          path_package.join(dbPath, '${Constant.databaseKeyName}.db');
      return await sqf.databaseFactoryFfi.openDatabase(
        path,
        options: sqf.OpenDatabaseOptions(
          version: Constant.dbVersion,
          onCreate: _insertTables,
          onUpgrade: _onUpdateVersion,
          singleInstance: true,
        ),
      );
    }
    final String path = testingMode
        ? inMemoryDatabasePath
        : path_package.join(
            await getDatabasesPath(), '${Constant.databaseKeyName}.db');
    return await openDatabase(
      path,
      version: Constant.dbVersion,
      onCreate: _insertTables,
      onUpgrade: _onUpdateVersion,
      singleInstance: true,
    );
  }

  /// Creates the database tables.
  Future<void> _insertTables(Database db, int version) async {
    for (Table table in tables) {
      await db.execute(table.toQuery());
    }
  }

  /// Updates the database schema.
  Future<void> _onUpdateVersion(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // If the user is at the version [2], and the current database
    // version is [5], this apply all the changes between both ranges
    // to the current db
    for (int i = oldVersion + 1; i <= newVersion; i++) {
      final List<Table>? migrationChanges = changes[i];
      if (migrationChanges != null) {
        for (final Table tableChange in migrationChanges) {
          await db.execute(tableChange.toQuery());
        }
      }
    }
  }
}
