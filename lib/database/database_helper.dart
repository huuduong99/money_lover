import 'package:money_lover/model/category_model.dart';
import 'package:money_lover/model/expense_model.dart';
import 'package:money_lover/model/payment_method_model.dart';
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
        "CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL , type INTEGER , category_id INTEGER, payment_method_id INTEGER, date TEXT)");
    await db.execute(
        "CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, category_name TEXT, parent_id INTEGER)");
    await db.execute(
        "CREATE TABLE payment_method(id INTEGER PRIMARY KEY AUTOINCREMENT, method_name TEXT,balance REAL)");
  }

  //Expense
  Future<void> insertExpense(Expense expense) async {
    final dbExpense = await database;
    await dbExpense.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Expense>> getExpenses() async {
    final dbExpense = await database;
    final List<Map<String, dynamic>> maps = await dbExpense.query('expenses');

    return List.generate(maps.length, (index) {
      return Expense.fromMap(maps[index]);
    });
  }

  Future<List<Expense>> getIncomes() async {
    final dbExpense = await database;
    final List<Map<String, dynamic>> maps =
    await dbExpense.query('expenses', where: "type = 1");

    return List.generate(maps.length, (index) {
      return Expense.fromMap(maps[index]);
    });
  }

  Future<List<Expense>> getSpendings() async {
    final dbExpense = await database;
    final List<Map<String, dynamic>> maps =
    await dbExpense.query('expenses', where: "type = 0");

    return List.generate(maps.length, (index) {
      return Expense.fromMap(maps[index]);
    });
  }

  Future<void> updateExpense(Expense expense) async {
    final dbExpense = await database;
    await dbExpense.update('expenses', expense.toMap(),
        where: "id= ?", whereArgs: [expense.id]);
  }

  Future<void> deleteExpense(int id) async {
    final dbExpense = await database;
    await dbExpense.delete('expenses', where: "id= ?", whereArgs: [id]);
  }

  Future calculateTotalEachTypeExpenses(int type, String startDate, String endDate) async {
    final dbExpense = await database;
    var sum;
    if (startDate == null && endDate == null) {
      sum = await dbExpense.rawQuery(
          "SELECT SUM(amount) as totalSum FROM expenses WHERE  type= ?",
          [type]);
    } else {
      sum = await dbExpense.rawQuery(
          "SELECT SUM(amount) as totalSum FROM expenses WHERE  type= ? AND (strftime(date) BETWEEN strftime(?) AND strftime(?))", [type, startDate, endDate]);
    }
    return sum;
  }

  Future<List<Expense>> getExpenseInDatetimeRange(String startDate, String endDate) async {
    final dbExpense = await database;
    List<Map<String, dynamic>> maps;

    if (startDate == null && endDate == null) {
      maps = await dbExpense.rawQuery("SELECT * FROM expenses ORDER BY strftime(date) DESC");
    } else {
      maps = await dbExpense.rawQuery(
          "SELECT * FROM expenses WHERE strftime(date) BETWEEN strftime (?) AND strftime (?) ORDER BY strftime(date) DESC", [startDate, endDate]);
    }

    return List.generate(maps.length, (index) {
      return Expense.fromMap(maps[index]);
    });
  }

  //Category
  Future<void> insertCategories(Category category) async {
    final dbCategories = await database;
    await dbCategories.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategories() async {
    final dbCategories = await database;
    final List<Map<String, dynamic>> maps =
    await dbCategories.query('categories');

    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

  Future<void> updateCategory(Category category) async {
    final dbCategories = await database;
    await dbCategories.update('categories', category.toMap(),
        where: "id= ?", whereArgs: [category.id]);
  }

  Future<void> deleteCategory(int id) async {
    final dbCategories = await database;
    await dbCategories.delete('categories', where: "id= ?", whereArgs: [id]);
  }

  Future<List<Category>> getCategoryById(int id) async {
    final dbCategories = await database;
    final List<Map<String, dynamic>> maps =
    await dbCategories.query('categories', where: "id= ?", whereArgs: [id]);

    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

  Future<List<Category>> getAllParentCateGory(int categoryId) async {
    final dbCategories = await database;
    final List<Map<String, dynamic>> maps = await dbCategories.query(
        'categories',
        where: "parent_id is null and id is not ? ORDER BY category_name DESC",
        whereArgs: [categoryId.toString()]);

    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

  Future<List<Category>> getChildrenOfCategory(int categoryId) async {
    final dbCategories = await database;
    final List<Map<String, dynamic>> maps = await dbCategories
        .query('categories', where: "parent_id= ?", whereArgs: [categoryId]);

    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

  Future<List<Category>> getAllChildrenCategory() async {
    final dbCategories = await database;
    final List<Map<String, dynamic>> maps = await dbCategories.query(
        'categories',
        where: "parent_id is not null ORDER BY category_name DESC");

    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

  //Payment Method
  Future<void> insertPaymentMethod(PaymentMethod paymentMethod) async {
    final dbPaymentMethod = await database;
    await dbPaymentMethod.insert('payment_method', paymentMethod.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PaymentMethod>> getPaymentMethod() async {
    final dbPaymentMethod = await database;
    final List<Map<String, dynamic>> maps = await dbPaymentMethod.query('payment_method');

    return List.generate(maps.length, (index) {
      return PaymentMethod.fromMap(maps[index]);
    });
  }

  Future<void> updatePaymentMethod(PaymentMethod paymentMethod) async {
    final dbPaymentMethod = await database;
    await dbPaymentMethod.update('payment_method', paymentMethod.toMap(),
        where: "id= ?", whereArgs: [paymentMethod.id]);
  }

  Future<void> deletePaymentMethod(int id) async {
    final dbPaymentMethod = await database;
    await dbPaymentMethod.delete('payment_method', where: "id= ?", whereArgs: [id]);
  }
}
