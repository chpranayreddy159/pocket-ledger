import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../shared/models/budget_model.dart';
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

    return openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await _createTransactionsTable(db);
    await _createBudgetsTable(db);
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createBudgetsTable(db);
    }
  }

  Future<void> _createTransactionsTable(Database db) async {
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

  Future<void> _createBudgetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL UNIQUE,
        budget_limit REAL NOT NULL,
        spent REAL NOT NULL DEFAULT 0
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

  Future<int> insertBudget(Budget budget) async {
    final db = await database;

    final data = budget.toMap();
    data.remove('id');

    return db.insert('budgets', {
      'category': data['category'],
      'budget_limit': data['limit'],
      'spent': data['spent'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Budget>> getBudgets() async {
    final db = await database;

    final result = await db.query('budgets', orderBy: 'category ASC');

    return result
        .map(
          (row) => Budget(
            id: row['id'] as int?,
            category: row['category'] as String,
            limit: (row['budget_limit'] as num).toDouble(),
            spent: (row['spent'] as num).toDouble(),
          ),
        )
        .toList();
  }

  Future<int> updateBudget(Budget budget) async {
    if (budget.id == null) {
      throw ArgumentError('Budget ID is required for update.');
    }

    final db = await database;

    return db.update(
      'budgets',
      {
        'category': budget.category,
        'budget_limit': budget.limit,
        'spent': budget.spent,
      },
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;

    return db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDatabase() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
