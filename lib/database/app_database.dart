import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/worker.dart';
import '../models/progress.dart';
import '../models/certificate.dart';
import '../utils/app_constants.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Workers Table
    await db.execute('''
      CREATE TABLE Workers (
        id TEXT PRIMARY KEY,
        workerCode TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        language TEXT NOT NULL
      )
    ''');

    // 2. Progress Table
    await db.execute('''
      CREATE TABLE Progress (
        workerId TEXT NOT NULL,
        moduleId TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        score INTEGER NOT NULL DEFAULT 0,
        mistakes INTEGER NOT NULL DEFAULT 0,
        attempts INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        PRIMARY KEY (workerId, moduleId)
      )
    ''');

    // 3. Certificates Table
    await db.execute('''
      CREATE TABLE Certificates (
        certificateId TEXT PRIMARY KEY,
        workerId TEXT NOT NULL,
        module TEXT NOT NULL,
        score INTEGER NOT NULL,
        issuedAt TEXT NOT NULL,
        qrCode TEXT NOT NULL
      )
    ''');

    // Seed default data from assets
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    try {
      final String workersData = await rootBundle.loadString('assets/data/workers.json');
      final List<dynamic> workersJson = json.decode(workersData);

      for (var item in workersJson) {
        await db.insert(
          'Workers',
          {
            'id': item['id'],
            'workerCode': item['workerCode'],
            'name': item['name'],
            'role': item['role'],
            'language': item['language'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Seed initial progress entry for WK001
        await db.insert(
          'Progress',
          {
            'workerId': item['id'],
            'moduleId': AppConstants.defaultModuleId,
            'completed': 0,
            'score': 0,
            'mistakes': 0,
            'attempts': 0,
            'completedAt': null,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    } catch (e) {
      // If asset loading fails during headless tests, insert default WK001 fallback
      await db.insert(
        'Workers',
        {
          'id': 'WK001',
          'workerCode': 'WK001',
          'name': 'Ramesh Tudu',
          'role': 'Factory Worker',
          'language': 'English',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // --- Worker Operations ---

  Future<Worker?> getWorkerByCodeOrId(String codeOrId) async {
    final db = await instance.database;
    final cleanCode = codeOrId.trim();

    final result = await db.query(
      'Workers',
      where: 'workerCode = ? OR id = ?',
      whereArgs: [cleanCode, cleanCode],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Worker.fromMap(result.first);
    }
    return null;
  }

  Future<List<Worker>> getAllWorkers() async {
    final db = await instance.database;
    final result = await db.query('Workers');
    return result.map((json) => Worker.fromMap(json)).toList();
  }

  // --- Progress Operations ---

  Future<WorkerProgress> getProgress(String workerId, String moduleId) async {
    final db = await instance.database;
    final result = await db.query(
      'Progress',
      where: 'workerId = ? AND moduleId = ?',
      whereArgs: [workerId, moduleId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return WorkerProgress.fromMap(result.first);
    }

    // Default uncompleted progress
    final initial = WorkerProgress(
      workerId: workerId,
      moduleId: moduleId,
      completed: false,
      score: 0,
      mistakes: 0,
      attempts: 0,
    );
    await db.insert('Progress', initial.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return initial;
  }

  Future<void> incrementAttempt(String workerId, String moduleId) async {
    final db = await instance.database;
    final current = await getProgress(workerId, moduleId);
    await db.update(
      'Progress',
      {'attempts': current.attempts + 1},
      where: 'workerId = ? AND moduleId = ?',
      whereArgs: [workerId, moduleId],
    );
  }

  Future<void> saveProgress(WorkerProgress progress) async {
    final db = await instance.database;
    await db.insert(
      'Progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> getWorkerStats(String workerId) async {
    final db = await instance.database;
    final progressList = await db.query(
      'Progress',
      where: 'workerId = ?',
      whereArgs: [workerId],
    );

    int completedCount = 0;
    int totalAttempts = 0;
    int sumScore = 0;

    for (var row in progressList) {
      if ((row['completed'] as int) == 1) completedCount++;
      totalAttempts += (row['attempts'] as int? ?? 0);
      sumScore += (row['score'] as int? ?? 0);
    }

    final avgScore = progressList.isNotEmpty ? (sumScore / progressList.length).round() : 0;

    final certs = await db.query(
      'Certificates',
      where: 'workerId = ?',
      whereArgs: [workerId],
    );

    return {
      'completedModules': completedCount,
      'totalAttempts': totalAttempts,
      'averageScore': avgScore,
      'certificatesEarned': certs.length,
    };
  }

  // --- Certificates Operations ---

  Future<void> saveCertificate(Certificate cert) async {
    final db = await instance.database;
    await db.insert(
      'Certificates',
      cert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Certificate>> getCertificatesForWorker(String workerId) async {
    final db = await instance.database;
    final result = await db.query(
      'Certificates',
      where: 'workerId = ?',
      whereArgs: [workerId],
      orderBy: 'issuedAt DESC',
    );
    return result.map((json) => Certificate.fromMap(json)).toList();
  }

  Future<Certificate?> verifyCertificate(String certificateIdOrQr) async {
    final db = await instance.database;
    final cleanCode = certificateIdOrQr.trim();

    // 1. Query SQLite first
    final result = await db.rawQuery('''
      SELECT c.*, w.name as workerName 
      FROM Certificates c
      LEFT JOIN Workers w ON c.workerId = w.id
      WHERE c.certificateId = ? OR c.qrCode = ?
      LIMIT 1
    ''', [cleanCode, cleanCode]);

    if (result.isNotEmpty) {
      return Certificate.fromMap(result.first);
    }

    return null;
  }
}
