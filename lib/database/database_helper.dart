import 'package:money_lover/model/category_model.dart';
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
        "CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, expense_content TEXT , amount REAL , type INTEGER , category_id INTEGER, date TEXT)");
    await db.execute(
        "CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, category_name , parent_id INTEGER)");
  }

  //Expense
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

  //Category
  Future<void> insertCategories(Category category) async {
    final dbCategories = await database;
    await dbCategories.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategories() async {
    final dbCategories = await database;
    final List<Map<String, dynamic>> maps = await dbCategories.query('categories');

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
    final List<Map<String, dynamic>> maps = await dbCategories.query('categories', where: "id= ?", whereArgs: [id]);

    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

  Future<List<Category>> getAllParentCateGory(int categoryId) async {
    final dbCategories = await database;
    final List<Map<String, dynamic>> maps = await dbCategories.query('categories', where: "parent_id is null and id is not ? ORDER BY category_name ASC",whereArgs: [categoryId.toString()]);

    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

  Future<List<Category>> getChildrenOfCategory(int categoryId) async {
    final dbCategories = await database;
    final List<Map<String, dynamic>> maps = await dbCategories.query('categories', where: "parent_id= ?", whereArgs: [categoryId]);

    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

  Future<List<Category>> getAllChildrenCategory() async {
    final dbCategories = await database;
    final List<Map<String, dynamic>> maps = await dbCategories.query('categories', where: "parent_id is not null ORDER BY category_name ASC");

    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

}
