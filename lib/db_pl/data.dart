import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_pl_entity.dart';
class PlDatabase {
  static final PlDatabase _instance = PlDatabase._internal();
  static Database? _database;
  factory PlDatabase() => _instance;
  PlDatabase._internal();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'pocket_ledger.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        sub_category TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT,
        created_at TEXT NOT NULL,
        UNIQUE(month, category)
      )
    ''');
    await db.execute('''
      CREATE TABLE templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        sub_category TEXT,
        amount REAL NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE templates (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          category TEXT NOT NULL,
          sub_category TEXT,
          amount REAL NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE budgets ADD COLUMN category TEXT');
      await db.execute('''
        CREATE TABLE budgets_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          month TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT,
          created_at TEXT NOT NULL,
          UNIQUE(month, category)
        )
      ''');
      await db.execute('''
        INSERT INTO budgets_new (id, month, amount, category, created_at)
        SELECT id, month, amount, NULL, created_at FROM budgets
      ''');
      await db.execute('DROP TABLE budgets');
      await db.execute('ALTER TABLE budgets_new RENAME TO budgets');
    }
  }
  Future<int> insertBill(BillEntity bill) async {
    final db = await database;
    return await db.insert('bills', bill.toMap());
  }
  Future<int> updateBill(BillEntity bill) async {
    final db = await database;
    return await db.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }
  Future<int> deleteBill(int id) async {
    final db = await database;
    return await db.delete(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<BillEntity?> getBillById(int id) async {
    final db = await database;
    final maps = await db.query(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return BillEntity.fromMap(maps.first);
  }
  Future<List<BillEntity>> getAllBills() async {
    final db = await database;
    final maps = await db.query('bills', orderBy: 'date DESC, created_at DESC');
    return maps.map((map) => BillEntity.fromMap(map)).toList();
  }
  Future<List<BillEntity>> getBillsByDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'bills',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => BillEntity.fromMap(map)).toList();
  }
  Future<List<BillEntity>> getBillsByMonth(String yearMonth) async {
    final db = await database;
    final maps = await db.query(
      'bills',
      where: 'date LIKE ?',
      whereArgs: ['$yearMonth%'],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => BillEntity.fromMap(map)).toList();
  }
  Future<List<BillEntity>> getBillsByYear(int year) async {
    final db = await database;
    final maps = await db.query(
      'bills',
      where: 'date LIKE ?',
      whereArgs: ['$year%'],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => BillEntity.fromMap(map)).toList();
  }
  Future<List<BillEntity>> getBillsByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'bills',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => BillEntity.fromMap(map)).toList();
  }
  Future<List<BillEntity>> getBillsByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'bills',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => BillEntity.fromMap(map)).toList();
  }
  Future<List<BillEntity>> getBillsByMonthAndType(
      String yearMonth, String type) async {
    final db = await database;
    final maps = await db.query(
      'bills',
      where: 'date LIKE ? AND type = ?',
      whereArgs: ['$yearMonth%', type],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => BillEntity.fromMap(map)).toList();
  }
  Future<List<BillEntity>> getBillsByMonthAndCategory(
      String yearMonth, String category) async {
    final db = await database;
    final maps = await db.query(
      'bills',
      where: 'date LIKE ? AND category = ?',
      whereArgs: ['$yearMonth%', category],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => BillEntity.fromMap(map)).toList();
  }
  Future<double> getTotalAmountByMonth(String yearMonth, String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM bills WHERE date LIKE ? AND type = ?',
      ['$yearMonth%', type],
    );
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return result.first['total'] as double;
  }
  Future<double> getTotalAmountByDate(String date, String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM bills WHERE date = ? AND type = ?',
      [date, type],
    );
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return result.first['total'] as double;
  }
  Future<double> getTotalAmountByYear(int year, String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM bills WHERE date LIKE ? AND type = ?',
      ['$year%', type],
    );
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return result.first['total'] as double;
  }
  Future<Map<String, double>> getCategoryAmountsByMonth(
      String yearMonth, String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM bills WHERE date LIKE ? AND type = ? GROUP BY category ORDER BY total DESC',
      ['$yearMonth%', type],
    );
    final Map<String, double> categoryAmounts = {};
    for (var row in result) {
      categoryAmounts[row['category'] as String] = row['total'] as double;
    }
    return categoryAmounts;
  }
  Future<Map<String, double>> getCategoryAmountsByYear(
      int year, String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM bills WHERE date LIKE ? AND type = ? GROUP BY category ORDER BY total DESC',
      ['$year%', type],
    );
    final Map<String, double> categoryAmounts = {};
    for (var row in result) {
      categoryAmounts[row['category'] as String] = row['total'] as double;
    }
    return categoryAmounts;
  }
  Future<List<Map<String, dynamic>>> getMonthlyStatsByYear(int year) async {
    final List<Map<String, dynamic>> monthlyStats = [];
    for (int month = 1; month <= 12; month++) {
      final monthStr = month.toString().padLeft(2, '0');
      final yearMonth = '$year-$monthStr';
      final income = await getTotalAmountByMonth(yearMonth, 'income');
      final expense = await getTotalAmountByMonth(yearMonth, 'expense');
      monthlyStats.add({
        'month': month,
        'yearMonth': yearMonth,
        'income': income,
        'expense': expense,
        'balance': income - expense,
      });
    }
    return monthlyStats;
  }
  Future<int> insertBudget(BudgetEntity budget) async {
    final db = await database;
    return await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<int> updateBudget(BudgetEntity budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }
  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<BudgetEntity?> getBudgetByMonth(String month, {String? category}) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: category == null
          ? 'month = ? AND category IS NULL'
          : 'month = ? AND category = ?',
      whereArgs: category == null ? [month] : [month, category],
    );
    if (maps.isEmpty) return null;
    return BudgetEntity.fromMap(maps.first);
  }
  Future<List<BudgetEntity>> getAllBudgets() async {
    final db = await database;
    final maps = await db.query('budgets', orderBy: 'month DESC, category ASC');
    return maps.map((map) => BudgetEntity.fromMap(map)).toList();
  }
  Future<List<BudgetEntity>> getBudgetsByMonth(String month) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
      orderBy: 'category ASC',
    );
    return maps.map((map) => BudgetEntity.fromMap(map)).toList();
  }
  Future<List<BudgetEntity>> getCategoryBudgetsByMonth(String month) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'month = ? AND category IS NOT NULL',
      whereArgs: [month],
      orderBy: 'category ASC',
    );
    return maps.map((map) => BudgetEntity.fromMap(map)).toList();
  }
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('bills');
    await db.delete('budgets');
  }
  Future<int> insertTemplate(TemplateEntity template) async {
    final db = await database;
    return await db.insert('templates', template.toMap());
  }
  Future<int> updateTemplate(TemplateEntity template) async {
    final db = await database;
    return await db.update(
      'templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }
  Future<int> deleteTemplate(int id) async {
    final db = await database;
    return await db.delete(
      'templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<TemplateEntity?> getTemplateById(int id) async {
    final db = await database;
    final maps = await db.query(
      'templates',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TemplateEntity.fromMap(maps.first);
  }
  Future<List<TemplateEntity>> getAllTemplates() async {
    final db = await database;
    final maps = await db.query('templates', orderBy: 'created_at DESC');
    return maps.map((map) => TemplateEntity.fromMap(map)).toList();
  }
  Future<List<TemplateEntity>> getTemplatesByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'templates',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => TemplateEntity.fromMap(map)).toList();
  }
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
