import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:anne_bebek_app/core/utils/error_handler.dart' as app_errors;

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
    try {
      // Web platformu için özel işlem
      if (kIsWeb) {
        // Web için sqflite_common_ffi_web kullan
        databaseFactory = databaseFactoryFfiWeb;

        return await openDatabase(
          _dbName,
          version: _dbVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onDowngrade: _onDowngrade,
        );
      }

      // Diğer platformlar için
      // Windows/Linux için sqflite_ffi'yi initialize et
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      String path;

      if (Platform.isWindows) {
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
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        'Veritabanı başlatılırken hata oluştu: $e',
      );
    }
  }

  /// Database oluşturma - Tüm tabloları ve index'leri oluştur
  Future<void> _onCreate(Database db, int version) async {
    try {
      await _createTables(db);
      await _createIndexes(db);
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        'Veritabanı tabloları oluşturulurken hata oluştu: $e',
      );
    }
  }

  /// Database güncelleme - Migration'ları çalıştır
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      for (int i = oldVersion + 1; i <= newVersion; i++) {
        await _runMigration(db, i);
      }
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        'Veritabanı güncellenirken hata oluştu: $e',
      );
    }
  }

  /// Database downgrade - Tüm tabloları yeniden oluştur
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    try {
      await _dropAllTables(db);
      await _onCreate(db, newVersion);
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        'Veritabanı eski sürüme düşürülürken hata oluştu: $e',
      );
    }
  }

  /// Tüm tabloları oluştur
  Future<void> _createTables(Database db) async {
    try {
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
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        'Veritabanı tabloları oluşturulurken hata oluştu: $e',
      );
    }
  }

  /// Index'leri oluştur - Performance optimizasyonu
  Future<void> _createIndexes(Database db) async {
    try {
      await db.execute(
        'CREATE INDEX idx_babies_mother_id ON babies(mother_id)',
      );
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
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        'Veritabanı indexleri oluşturulurken hata oluştu: $e',
      );
    }
  }

  /// Migration çalıştırma
  Future<void> _runMigration(Database db, int version) async {
    try {
      switch (version) {
        case 2:
          // Version 2 migration'ları - Kolon ekleme işlemleri
          try {
            await db.execute('ALTER TABLE mothers ADD COLUMN phone TEXT');
          } catch (e) {
            // Kolon zaten varsa hata verme
            debugPrint('Phone column already exists in mothers table');
          }

          try {
            await db.execute('ALTER TABLE babies ADD COLUMN allergies TEXT');
          } catch (e) {
            debugPrint('Allergies column already exists in babies table');
          }

          try {
            await db.execute('ALTER TABLE mothers ADD COLUMN email TEXT');
          } catch (e) {
            debugPrint('Email column already exists in mothers table');
          }

          try {
            await db.execute(
              'ALTER TABLE babies ADD COLUMN medical_notes TEXT',
            );
          } catch (e) {
            debugPrint('Medical_notes column already exists in babies table');
          }
          break;
        // Gelecek migration'lar buraya eklenecek
        default:
          break;
      }
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        'Veritabanı migration işlemi sırasında hata oluştu: $e',
      );
    }
  }

  /// Tüm tabloları sil - Downgrade için
  Future<void> _dropAllTables(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS vaccination_tracking');
      await db.execute('DROP TABLE IF EXISTS growth_tracking');
      await db.execute('DROP TABLE IF EXISTS feeding_tracking');
      await db.execute('DROP TABLE IF EXISTS sleep_tracking');
      await db.execute('DROP TABLE IF EXISTS babies');
      await db.execute('DROP TABLE IF EXISTS mothers');
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        'Veritabanı tabloları silinirken hata oluştu: $e',
      );
    }
  }

  // CRUD İşlemleri

  /// Uygulamadaki TÜM verileri kalıcı olarak siler.
  ///
  /// Tüm tabloları düşürür ve yeniden oluşturur. Bu işlem geri alınamaz.
  Future<void> deleteAllData() async {
    try {
      final db = await instance.database;
      await _dropAllTables(db);
      await _createTables(db);
      await _createIndexes(db);
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        'Tüm veriler silinirken hata oluştu: $e',
      );
    }
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    try {
      final db = await instance.database;
      return await db.insert(table, row);
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        '$table tablosuna kayıt eklenirken hata oluştu: $e',
      );
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    int? limit,
    String? orderBy,
  }) async {
    try {
      final db = await instance.database;
      return await db.query(
        table,
        where: where,
        whereArgs: whereArgs,
        limit: limit,
        orderBy: orderBy,
      );
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        '$table tablosundan veri alınırken hata oluştu: $e',
      );
    }
  }

  Future<int> update(
    String table,
    Map<String, dynamic> row, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final db = await instance.database;
      return await db.update(table, row, where: where, whereArgs: whereArgs);
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        '$table tablosunda güncelleme yapılırken hata oluştu: $e',
      );
    }
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final db = await instance.database;
      return await db.delete(table, where: where, whereArgs: whereArgs);
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw app_errors.DatabaseException(
        '$table tablosundan silme işlemi yapılırken hata oluştu: $e',
      );
    }
  }
}
