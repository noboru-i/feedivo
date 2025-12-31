import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLiteデータベースサービス
/// オフライン対応のためのローカルキャッシュを管理
class DatabaseService {
  DatabaseService._();

  static Database? _database;

  /// データベースインスタンスを取得
  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// データベースを初期化
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'feedivo.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// データベーススキーマを作成
  static Future<void> _onCreate(Database db, int version) async {
    // チャンネルテーブル
    await db.execute('''
      CREATE TABLE channels (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        thumbnail_file_id TEXT,
        config_file_id TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        synced_at INTEGER NOT NULL
      )
    ''');

    // 動画テーブル
    await db.execute('''
      CREATE TABLE videos (
        id TEXT PRIMARY KEY,
        channel_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        video_file_id TEXT NOT NULL,
        thumbnail_file_id TEXT,
        duration INTEGER NOT NULL,
        published_at INTEGER NOT NULL,
        cached_at INTEGER NOT NULL,
        FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
      )
    ''');

    // 視聴位置テーブル
    await db.execute('''
      CREATE TABLE playback_positions (
        video_id TEXT PRIMARY KEY,
        channel_id TEXT NOT NULL,
        position INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        last_played_at INTEGER NOT NULL,
        is_completed INTEGER NOT NULL,
        synced_at INTEGER NOT NULL
      )
    ''');

    // インデックス作成
    await db.execute(
      'CREATE INDEX idx_videos_channel_id ON videos(channel_id)',
    );
    await db.execute(
      'CREATE INDEX idx_channels_user_id ON channels(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_playback_positions_last_played_at ON playback_positions(last_played_at DESC)',
    );
  }

  /// データベーススキーマのアップグレード
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // 将来のマイグレーション用
    // 現在はバージョン1のみなので何もしない
  }

  /// データベースを閉じる
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// データベースを削除（テスト用）
  static Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'feedivo.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
