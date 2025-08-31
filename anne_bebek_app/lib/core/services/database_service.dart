import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static const String _dbName = "anne_bebek.db";
  static const int _dbVersion =
      2; // Version artırıldı - Migration sistemi eklendi

  // Singleton instance
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Windows platformu için sqflite_ffi'yi initialize et
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;

    if (kIsWeb) {
      // Web platformu için
      path = _dbName;
    } else if (Platform.isWindows) {
      // Windows platformu için alternatif yol - Geçici dizin kullan
      Directory tempDirectory = await getTemporaryDirectory();
      path = join(tempDirectory.path, _dbName);
    } else {
      // Diğer platformlar için normal yol
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, _dbName);
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  /// Database oluşturma - Tüm tabloları ve index'leri oluştur
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
  }

  /// Database güncelleme - Migration'ları çalıştır
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int i = oldVersion + 1; i <= newVersion; i++) {
      await _runMigration(db, i);
    }
  }

  /// Database downgrade - Tüm tabloları yeniden oluştur
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    await _dropAllTables(db);
    await _onCreate(db, newVersion);
  }

  /// Tüm tabloları oluştur
  Future<void> _createTables(Database db) async {
    // Mothers tablosu
    await db.execute('''
      CREATE TABLE mothers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birth_date TEXT,
        birth_city TEXT,
        astrology_enabled INTEGER DEFAULT 0,
        zodiac_sign TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Babies tablosu
    await db.execute('''
      CREATE TABLE babies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mother_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        birth_time TEXT,
        birth_weight REAL,
        birth_height REAL,
        birth_head_circumference REAL,
        birth_city TEXT,
        gender TEXT,
        zodiac_sign TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (mother_id) REFERENCES mothers (id) ON DELETE CASCADE
      )
    ''');

    // Sağlık takibi tabloları
    await db.execute('''
      CREATE TABLE sleep_tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        sleep_start TEXT NOT NULL,
        sleep_end TEXT,
        duration_minutes INTEGER,
        sleep_quality TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (baby_id) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE feeding_tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        feeding_type TEXT NOT NULL,
        feeding_time TEXT NOT NULL,
        amount_ml REAL,
        duration_minutes INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (baby_id) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE growth_tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        measurement_date TEXT NOT NULL,
        weight_kg REAL,
        height_cm REAL,
        head_circumference_cm REAL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (baby_id) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE vaccination_tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        vaccine_name TEXT NOT NULL,
        vaccine_date TEXT NOT NULL,
        next_dose_date TEXT,
        administered_by TEXT,
        batch_number TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (baby_id) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Index'leri oluştur - Performance optimizasyonu
  Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_babies_mother_id ON babies(mother_id)');
    await db.execute(
      'CREATE INDEX idx_sleep_baby_id ON sleep_tracking(baby_id)',
    );
    await db.execute(
      'CREATE INDEX idx_feeding_baby_id ON feeding_tracking(baby_id)',
    );
    await db.execute(
      'CREATE INDEX idx_growth_baby_id ON growth_tracking(baby_id)',
    );
    await db.execute(
      'CREATE INDEX idx_vaccination_baby_id ON vaccination_tracking(baby_id)',
    );
    await db.execute('CREATE INDEX idx_mothers_name ON mothers(name)');
    await db.execute('CREATE INDEX idx_babies_name ON babies(name)');
  }

  /// Migration çalıştırma
  Future<void> _runMigration(Database db, int version) async {
    switch (version) {
      case 2:
        // Version 2 migration'ları
        await db.execute('ALTER TABLE mothers ADD COLUMN phone TEXT');
        await db.execute('ALTER TABLE babies ADD COLUMN allergies TEXT');
        await db.execute('ALTER TABLE mothers ADD COLUMN email TEXT');
        await db.execute('ALTER TABLE babies ADD COLUMN medical_notes TEXT');
        break;
      // Gelecek migration'lar buraya eklenecek
      default:
        break;
    }
  }

  /// Tüm tabloları sil - Downgrade için
  Future<void> _dropAllTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS vaccination_tracking');
    await db.execute('DROP TABLE IF EXISTS growth_tracking');
    await db.execute('DROP TABLE IF EXISTS feeding_tracking');
    await db.execute('DROP TABLE IF EXISTS sleep_tracking');
    await db.execute('DROP TABLE IF EXISTS babies');
    await db.execute('DROP TABLE IF EXISTS mothers');
  }

  // CRUD İşlemleri

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    int? limit,
    String? orderBy,
  }) async {
    final db = await instance.database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
      orderBy: orderBy,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> row, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await instance.database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await instance.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}
