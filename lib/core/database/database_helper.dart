import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../shared/models/transaction_model.dart';
import 'tables.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'pocket_ledger.db');

    return openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Tables.transactions} (
        ${Tables.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Tables.title} TEXT NOT NULL,
        ${Tables.amount} REAL NOT NULL,
        ${Tables.type} TEXT NOT NULL,
        ${Tables.category} TEXT NOT NULL,
        ${Tables.date} TEXT NOT NULL,
        ${Tables.note} TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;

    final data = transaction.toMap();
    data.remove(Tables.id);

    return db.insert(
      Tables.transactions,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;

    final result = await db.query(
      Tables.transactions,
      orderBy: '${Tables.date} DESC',
    );

    return result
        .map((transaction) => TransactionModel.fromMap(transaction))
        .toList();
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await database;

    final result = await db.query(
      Tables.transactions,
      where: '${Tables.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return TransactionModel.fromMap(result.first);
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('Transaction ID is required for update.');
    }

    final db = await database;

    return db.update(
      Tables.transactions,
      transaction.toMap(),
      where: '${Tables.id} = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      Tables.transactions,
      where: '${Tables.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllTransactions() async {
    final db = await database;
    await db.delete(Tables.transactions);
  }

  Future<double> getTotalIncome() async {
    return _getTotalByType('income');
  }

  Future<double> getTotalExpenses() async {
    return _getTotalByType('expense');
  }

  Future<double> _getTotalByType(String type) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT SUM(${Tables.amount}) AS total
      FROM ${Tables.transactions}
      WHERE ${Tables.type} = ?
      ''',
      [type],
    );

    final value = result.first['total'];

    if (value == null) {
      return 0;
    }

    return (value as num).toDouble();
  }

  Future<void> closeDatabase() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
