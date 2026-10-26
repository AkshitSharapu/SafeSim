import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/worker.dart';
import '../models/worker_identity.dart';
import '../models/simulation_result.dart';
import '../models/progress.dart';
import '../models/certificate.dart';
import '../utils/app_constants.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;
  static Future<Database>? _opening;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await (_opening ??= _initDB(AppConstants.databaseName));
      return _database!;
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final String path;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onUpgrade: (db, oldVersion, newVersion) async { await _createTrainingTables(db); },
      onCreate: _createDB,
      onOpen: (db) async {
        await _ensureTablesAndSeed(db);
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Workers Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Workers (
        id TEXT PRIMARY KEY,
        workerCode TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        language TEXT NOT NULL,
        qr TEXT,
        department TEXT
      )
    ''');

    // 2. Progress Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Progress (
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
      CREATE TABLE IF NOT EXISTS Certificates (
        certificateId TEXT PRIMARY KEY,
        workerId TEXT NOT NULL,
        module TEXT NOT NULL,
        score INTEGER NOT NULL,
        issuedAt TEXT NOT NULL,
        qrCode TEXT NOT NULL
      )
    ''');

    // 4. Server Sync Table for Manager Status Push
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ServerSync (
        workerId TEXT PRIMARY KEY,
        syncStatus TEXT NOT NULL DEFAULT 'OFFLINE_PENDING',
        managerApproved INTEGER NOT NULL DEFAULT 0,
        managerName TEXT,
        managerNotes TEXT,
        serverReceiptId TEXT,
        lastSyncedAt TEXT
      )
    ''');

    await _createTrainingTables(db);
    await _seedInitialData(db);
  }

  Future<void> _ensureTablesAndSeed(Database db) async {
    // Ensure all tables exist in case of older SQLite version
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Workers (
        id TEXT PRIMARY KEY,
        workerCode TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        language TEXT NOT NULL,
        qr TEXT,
        department TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Progress (
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Certificates (
        certificateId TEXT PRIMARY KEY,
        workerId TEXT NOT NULL,
        module TEXT NOT NULL,
        score INTEGER NOT NULL,
        issuedAt TEXT NOT NULL,
        qrCode TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ServerSync (
        workerId TEXT PRIMARY KEY,
        syncStatus TEXT NOT NULL DEFAULT 'OFFLINE_PENDING',
        managerApproved INTEGER NOT NULL DEFAULT 0,
        managerName TEXT,
        managerNotes TEXT,
        serverReceiptId TEXT,
        lastSyncedAt TEXT
      )
    ''');

    // Seed or update the 3 official workers
    await _createTrainingTables(db);
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final defaultWorkers = [
      {
        'id': 'WK001',
        'workerCode': 'WK001',
        'name': 'Sharapu Akshit',
        'role': 'Lead Safety Officer & Operations',
        'language': 'English',
        'qr': 'WK001',
        'department': 'Mining & Plant Div. 04',
      },
      {
        'id': 'WK002',
        'workerCode': 'WK002',
        'name': 'Rishitha Reddy',
        'role': 'Furnace Operations Specialist',
        'language': 'English',
        'qr': 'WK002',
        'department': 'Blast Furnace Div. 02',
      },
      {
        'id': 'WK003',
        'workerCode': 'WK003',
        'name': 'Srinivas',
        'role': 'Heavy Machinery & Rigging Operator',
        'language': 'English',
        'qr': 'WK003',
        'department': 'Ore Extraction Div. 01',
      },
    ];

    try {
      // Try loading workers.json if available
      final String workersData = await rootBundle.loadString('assets/data/workers.json');
      final List<dynamic> workersJson = json.decode(workersData);

      for (var item in workersJson) {
        await _upsertWorkerRecord(db, Map<String, dynamic>.from(item));
      }
    } catch (_) {
      // Fallback to static definitions
      for (var worker in defaultWorkers) {
        await _upsertWorkerRecord(db, worker);
      }
    }
  }

  Future<void> _upsertWorkerRecord(Database db, Map<String, dynamic> item) async {
    final workerId = item['id'] as String;
    await db.insert(
      'Workers',
      {
        'id': workerId,
        'workerCode': item['workerCode'] ?? workerId,
        'name': item['name'] ?? 'Industrial Worker',
        'role': item['role'] ?? 'Operator',
        'language': item['language'] ?? 'English',
        'qr': item['qr'] ?? workerId,
        'department': item['department'] ?? 'Mining & Plant Div. 04',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Initial progress entry for default module
    await db.insert(
      'Progress',
      {
        'workerId': workerId,
        'moduleId': AppConstants.defaultModuleId,
        'completed': 0,
        'score': 0,
        'mistakes': 0,
        'attempts': 0,
        'completedAt': null,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Initial server sync state
    await db.insert(
      'ServerSync',
      {
        'workerId': workerId,
        'syncStatus': 'OFFLINE_PENDING',
        'managerApproved': 0,
        'managerName': null,
        'managerNotes': null,
        'serverReceiptId': null,
        'lastSyncedAt': null,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // --- Worker Operations ---

  Future<Worker?> getWorkerByCodeOrId(String codeOrId) async {
    final db = await instance.database;
    String id;
    try { id = WorkerIdentity.decode(codeOrId); } on FormatException { return null; }
    final result = await db.rawQuery(
      'SELECT * FROM Workers WHERE UPPER(id) = ? OR UPPER(workerCode) = ?', [id, id]);
    // Ambiguous legacy records must never select the wrong worker.
    if (result.length != 1) return null;

    if (result.isNotEmpty) {
      return Worker.fromMap(result.first);
    }
    return null;
  }

  Future<List<Worker>> getAllWorkers() async {
    final db = await instance.database;
    final result = await db.query('Workers', orderBy: 'id ASC');
    return result.map((json) => Worker.fromMap(json)).toList();
  }

  Future<Worker> createWorker({required String id, required String name,
    required String role, required String department, String language = 'English'}) async {
    final cleanId = WorkerIdentity.normalize(id);
    if (name.trim().isEmpty || role.trim().isEmpty || department.trim().isEmpty) {
      throw const FormatException('Name, role and department are required.');
    }
    if ([name, role, department, language].any((v) => v.trim().length > 120)) {
      throw const FormatException('Please keep each field under 120 characters.');
    }
    final worker = Worker(id: cleanId, workerCode: cleanId, name: name.trim(),
      role: role.trim(), department: department.trim(), language: language.trim(),
      qr: WorkerIdentity.encode(cleanId));
    final db = await database;
    await db.transaction((txn) async {
      final existing = await txn.rawQuery(
        'SELECT id FROM Workers WHERE UPPER(id) = ? OR UPPER(workerCode) = ?', [cleanId, cleanId]);
      if (existing.isNotEmpty) throw const FormatException('That Worker ID already exists. Use a different ID.');
      await txn.insert('Workers', worker.toMap());
      await txn.insert('Progress', {'workerId': cleanId, 'moduleId': AppConstants.defaultModuleId,
        'completed': 0, 'score': 0, 'mistakes': 0, 'attempts': 0, 'completedAt': null});
      await txn.insert('ServerSync', {'workerId': cleanId, 'syncStatus': 'OFFLINE_PENDING', 'managerApproved': 0});
    });
    return worker;
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

    // When progress changes, set ServerSync status back to OFFLINE_PENDING until manager pushes
    await db.update(
      'ServerSync',
      {
        'syncStatus': 'OFFLINE_PENDING',
        'managerApproved': 0,
      },
      where: 'workerId = ?',
      whereArgs: [progress.workerId],
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

    final syncData = await getServerSyncStatus(workerId);

    return {
      'completedModules': completedCount,
      'totalAttempts': totalAttempts,
      'averageScore': avgScore,
      'certificatesEarned': certs.length,
      'syncStatus': syncData['syncStatus'] ?? 'OFFLINE_PENDING',
      'managerApproved': (syncData['managerApproved'] ?? 0) == 1,
      'managerName': syncData['managerName'] ?? 'Shift Manager',
      'serverReceiptId': syncData['serverReceiptId'],
      'lastSyncedAt': syncData['lastSyncedAt'],
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

  // --- Manager Server Sync Operations ---

  Future<Map<String, dynamic>> getServerSyncStatus(String workerId) async {
    final db = await instance.database;
    final result = await db.query(
      'ServerSync',
      where: 'workerId = ?',
      whereArgs: [workerId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return {
      'workerId': workerId,
      'syncStatus': 'OFFLINE_PENDING',
      'managerApproved': 0,
      'managerName': null,
      'managerNotes': null,
      'serverReceiptId': null,
      'lastSyncedAt': null,
    };
  }

  Future<Map<String, dynamic>> updateManagerServerSync({
    required String workerId,
    required String managerName,
    String? notes,
  }) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    final receiptId = 'LOCAL-REVIEW-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';

    final data = {
      'workerId': workerId,
      'syncStatus': 'LOCAL_REVIEWED',
      'managerApproved': 1,
      'managerName': managerName,
      'managerNotes': notes ?? 'Local review recorded on this device; no server transmission.',
      'serverReceiptId': receiptId,
      'lastSyncedAt': now,
    };

    await db.insert(
      'ServerSync',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return data;
  }
  Future<void> _createTrainingTables(DatabaseExecutor db) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS SimulationAttempts (
      sessionId TEXT PRIMARY KEY, workerId TEXT NOT NULL, moduleId TEXT NOT NULL,
      passed INTEGER NOT NULL CHECK(passed IN (0,1)),
      score INTEGER NOT NULL CHECK(score BETWEEN 0 AND 100),
      mistakes INTEGER NOT NULL CHECK(mistakes >= 0), duration INTEGER NOT NULL CHECK(duration >= 0),
      recordedAt TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE IF NOT EXISTS QuizResults (
      workerId TEXT NOT NULL, moduleId TEXT NOT NULL,
      score INTEGER NOT NULL CHECK(score BETWEEN 0 AND 100),
      mistakes INTEGER NOT NULL CHECK(mistakes >= 0), recordedAt TEXT NOT NULL,
      PRIMARY KEY(workerId, moduleId)
    )''');
  }

  Future<void> recordSimulation(SimulationResult result) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('SimulationAttempts', {
        'sessionId': result.sessionId, 'workerId': result.workerId, 'moduleId': result.moduleId,
        'passed': result.passed ? 1 : 0, 'score': result.score,
        'mistakes': result.mistakes, 'duration': result.duration,
        'recordedAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await _recalculateProgress(txn, result.workerId, result.moduleId);
    });
  }

  Future<void> recordQuiz(String workerId, String moduleId, int score, int mistakes) async {
    if (score < 0 || score > 100 || mistakes < 0) throw ArgumentError('Invalid quiz result');
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('QuizResults', {'workerId': workerId, 'moduleId': moduleId,
        'score': score, 'mistakes': mistakes, 'recordedAt': DateTime.now().toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.replace);
      await _recalculateProgress(txn, workerId, moduleId);
    });
  }

  Future<void> _recalculateProgress(DatabaseExecutor db, String workerId, String moduleId) async {
    final attempts = await db.rawQuery('''SELECT COUNT(*) AS count,
      COALESCE(MAX(score),0) AS bestScore, COALESCE(MAX(passed),0) AS passed
      FROM SimulationAttempts WHERE workerId = ? AND moduleId = ?''', [workerId, moduleId]);
    final quiz = await db.query('QuizResults', where: 'workerId = ? AND moduleId = ?',
      whereArgs: [workerId, moduleId], limit: 1);
    final quizScore = quiz.isEmpty ? 0 : quiz.first['score'] as int;
    final complete = attempts.first['passed'] == 1 && quizScore >= 70;
    await db.insert('Progress', {'workerId': workerId, 'moduleId': moduleId,
      'completed': complete ? 1 : 0,
      'score': complete ? quizScore : attempts.first['bestScore'],
      'mistakes': quiz.isEmpty ? 0 : quiz.first['mistakes'],
      'attempts': attempts.first['count'],
      'completedAt': complete ? DateTime.now().toIso8601String() : null,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.update('ServerSync', {'syncStatus': 'OFFLINE_PENDING', 'managerApproved': 0},
      where: 'workerId = ?', whereArgs: [workerId]);
  }

  Future<bool> canIssueCertificate(String workerId, String moduleId) async {
    final db = await database;
    final rows = await db.rawQuery('''SELECT 1 FROM QuizResults q
      WHERE q.workerId = ? AND q.moduleId = ? AND q.score >= 70
      AND EXISTS (SELECT 1 FROM SimulationAttempts s
        WHERE s.workerId = q.workerId AND s.moduleId = q.moduleId AND s.passed = 1)
      LIMIT 1''', [workerId, moduleId]);
    return rows.isNotEmpty;
  }

  Future<int?> verifiedQuizScore(String workerId, String moduleId) async {
    if (!await canIssueCertificate(workerId, moduleId)) return null;
    final db = await database;
    final rows = await db.query('QuizResults', where: 'workerId = ? AND moduleId = ?',
      whereArgs: [workerId, moduleId], limit: 1);
    return rows.first['score'] as int;
  }

}
