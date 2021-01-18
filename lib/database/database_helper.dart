import 'package:money_lover/model/expense_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db;
    } else {
      _db = await openDatabase(
          join(await getDatabasesPath(), 'expense_database'),
          version: 1,
          onCreate: _onCreate);
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, expense_content TEXT, amount REAL, type INTEGER, date TEXT)");
  }

  Future<void> insertExpense(Expense expense) async {
    final dbExpanse = await database;
    await dbExpanse.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Expense>> getExpenses() async {
    final dbExpanse = await database;
    final List<Map<String, dynamic>> maps = await dbExpanse.query('expenses');

    return List.generate(maps.length, (index) {
      return Expense.fromMap(maps[index]);
    });
  }

  Future<List<Expense>> getIncomes() async {
    final dbExpanse = await database;
    final List<Map<String, dynamic>> maps =
        await dbExpanse.query('expenses', where: "type = 1");

    return List.generate(maps.length, (index) {
      return Expense.fromMap(maps[index]);
    });
  }

  Future<List<Expense>> getSpendings() async {
    final dbExpanse = await database;
    final List<Map<String, dynamic>> maps =
        await dbExpanse.query('expenses', where: "type = 0");

    return List.generate(maps.length, (index) {
      return Expense.fromMap(maps[index]);
    });
  }

  Future<void> updateExpense(Expense expense) async {
    final dbExpanse = await database;
    await dbExpanse.update('expenses', expense.toMap(),
        where: "id= ?", whereArgs: [expense.id]);
  }

  Future<void> deleteExpense(int id) async {
    final dbExpanse = await database;
    await dbExpanse.delete('expenses', where: "id= ?", whereArgs: [id]);
  }
}
