import 'package:auto_deployment/src/data/local/database.dart';
import 'package:sqflite/sqflite.dart';

class DeploymentProvider {
  late final Database database;

  DeploymentProvider._();

  static DeploymentProvider instance = DeploymentProvider._();

  Future<void> setup([Database? db]) async {
    database = db ?? await AutoDeployDatabase.instance().database();
  }

  /// Executes a fast query and returns the list of objects
  Future<List<Map<String, Object?>>> query(
    String query, {
    List<Object?> args = const [],
  }) async {
    return await database.rawQuery(
      query,
      <Object?>[...args],
    );
  }

  /// Executes a fast insert and returns the new id
  /// for the new element inserted
  Future<int> insert(
    String table, {
    required Map<String, Object?> values,
  }) async {
    return await database.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Executes a fast delete and returns a boolean to
  /// know if the changed was do it sucessfully
  Future<bool> delete(
    String query, {
    List<Object?> args = const [],
  }) async {
    return (await database.delete(
          query,
          where: 'id = ?',
          whereArgs: args,
        )) >
        0;
  }

  /// Executes a fast updated and returns a boolean to
  /// know if the changed was do it sucessfully
  Future<bool> update(
    String table, {
    String? where,
    required Map<String, Object?> values,
    required List<Object?> args,
  }) async {
    return (await database.update(
          table,
          values,
          where: where ?? 'id = ?',
          whereArgs: [...args],
        )) >
        0;
  }

  void close() async {
    await database.close();
  }
}
