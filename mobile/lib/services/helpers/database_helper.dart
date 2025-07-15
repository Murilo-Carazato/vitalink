import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  //Singleton
  // Construtor com acesso privado
  DatabaseHelper._();

  // Criar uma instância estática do DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._();

  // Criar uma instância do SQLiteDatabase
  static Database? _database;

  get database async {
    if (_database != null) return _database;
    return await _initDatabase();
  }

  _initDatabase() async {
    Database localStorage = await openDatabase(
      join(await getDatabasesPath(), 'bloodbank.db'),
      version: 5, // <- mudei de 4 para 5
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return localStorage;
  }

  _onCreate(Database db, version) async {
    await db.execute(_user);
    await db.execute(_followedBloodCenter);
    await db.execute(_donate);
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE User ADD COLUMN email TEXT');
      await db.execute('ALTER TABLE User ADD COLUMN token TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE User ADD COLUMN profile_photo_path TEXT');
    }
    if (oldVersion < 4) {
      // Recria a tabela de usuário para usar o ID do servidor como chave primária
      await db.execute('DROP TABLE IF EXISTS User');
      await db.execute(_user);
    }
    if (oldVersion < 5) {
      // Garante que a tabela User seja recriada com a nova estrutura.
      await db.execute('DROP TABLE IF EXISTS User');
      await db.execute(_user);
    }
  }

  String get _user => '''
    CREATE TABLE IF NOT EXISTS User (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        bloodType TEXT NOT NULL,
        hasTattoo INTEGER NOT NULL,
        hasMicropigmentation INTEGER NOT NULL,
        hasPermanentMakeup INTEGER NOT NULL,
        viewedTutorial INTEGER NOT NULL DEFAULT 0,
        email TEXT,
        token TEXT,
        profile_photo_path TEXT
        );
    ''';

  String get _followedBloodCenter => '''
    CREATE TABLE IF NOT EXISTS BloodCenter (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        site TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        isLiked INTEGER DEFAULT 1
        );
    ''';

  String get _donate => '''
    CREATE TABLE IF NOT EXISTS Donate (
        id INTEGER PRIMARY KEY,
        bloodCenterId INTEGER,
        date TEXT NOT NULL,
        FOREIGN KEY (bloodCenterId) REFERENCES BloodCenter(id)
        );
    ''';
}
