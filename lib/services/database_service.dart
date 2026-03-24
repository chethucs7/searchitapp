import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/record_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'datasearch.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          search_text TEXT NOT NULL,
          row_data TEXT NOT NULL
        )
      ''');

      // Create index for fast search
      await db.execute('''
        CREATE INDEX idx_search_text ON records(search_text)
      ''');
    } catch (e) {
      // Silent fail - table may exist
    }
  }

  // Insert a record
  Future<int> insertRecord(ExcelRecord record) async {
    try {
      final db = await database;
      return await db.insert('records', record.toMap());
    } catch (e) {
      return -1;
    }
  }

  // Insert multiple records with optimized batching
  // Uses single transaction for entire batch
  Future<int> insertRecords(List<ExcelRecord> records) async {
    if (records.isEmpty) return 0;

    try {
      final db = await database;
      int count = 0;

      // Single transaction for all records in batch
      await db.transaction((txn) async {
        for (var record in records) {
          await txn.insert('records', record.toMap());
          count++;
        }
      });

      return count;
    } catch (e) {
      return 0;
    }
  }

  /// Insert records in optimal batch size with transaction
  Future<int> insertRecordsOptimized(
    List<ExcelRecord> records, {
    int batchSize = 500,
  }) async {
    if (records.isEmpty) return 0;

    try {
      final db = await database;
      int totalCount = 0;

      // Process batches
      for (int i = 0; i < records.length; i += batchSize) {
        final end =
            (i + batchSize > records.length) ? records.length : i + batchSize;
        final batch = records.sublist(i, end);

        // Single transaction per batch
        final batchCount = await db.transaction((txn) async {
          int count = 0;
          for (var record in batch) {
            await txn.insert('records', record.toMap());
            count++;
          }
          return count;
        });

        totalCount += batchCount;
      }

      return totalCount;
    } catch (e) {
      return 0;
    }
  }

  // Get all records
  Future<List<ExcelRecord>> getAllRecords() async {
    try {
      final db = await database;
      final result = await db.query('records');
      return result.map((map) => ExcelRecord.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get total record count
  Future<int> getRecordCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM records');
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Search records
  Future<List<ExcelRecord>> searchRecords(String keyword) async {
    try {
      if (keyword.isEmpty) {
        return [];
      }

      final db = await database;
      final searchKeyword = '%${keyword.toUpperCase()}%';

      final result = await db.query(
        'records',
        where: 'UPPER(search_text) LIKE ?',
        whereArgs: [searchKeyword],
        limit: 1000,
      );

      return result.map((map) => ExcelRecord.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  // Delete all records
  Future<void> deleteAllRecords() async {
    try {
      final db = await database;
      await db.delete('records');
    } catch (e) {
      // Silent fail
    }
  }

  // Close database
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Get total record count - Optimized query
  Future<int> getTotalRecords() async {
    try {
      final db = await database;
      const query = 'SELECT COUNT(*) as count FROM records';
      final count = Sqflite.firstIntValue(
        await db.rawQuery(query),
      );
      return count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get database file size in bytes
  Future<int> getDatabaseFileSize() async {
    try {
      final dbPath = await getDatabasePath();
      final file = File(dbPath);
      if (file.existsSync()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get database file path
  Future<String> getDatabasePath() async {
    try {
      final db = await database;
      return db.path;
    } catch (e) {
      return '';
    }
  }

  /// Optimize database by running VACUUM
  /// Reduces database file size and improves query performance
  Future<void> optimizeDatabase() async {
    try {
      final db = await database;
      await db.rawQuery('VACUUM');
    } catch (e) {
      // Silent fail
    }
  }

  /// Analyze database to improve query performance
  /// Updates index statistics
  Future<void> analyzeDatabase() async {
    try {
      final db = await database;
      await db.rawQuery('ANALYZE');
    } catch (e) {
      // Silent fail
    }
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;
      final recordCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) as count FROM records'),
      ) ?? 0;

      final pageCount = Sqflite.firstIntValue(
        await db.rawQuery('PRAGMA page_count'),
      ) ?? 0;

      final pageSize = Sqflite.firstIntValue(
        await db.rawQuery('PRAGMA page_size'),
      ) ?? 0;

      final fileSizeBytes = await getDatabaseFileSize();

      return {
        'totalRecords': recordCount,
        'fileSize': fileSizeBytes,
        'fileSizeMB': (fileSizeBytes / (1024 * 1024)).toStringAsFixed(2),
        'pageCount': pageCount,
        'pageSize': pageSize,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}
