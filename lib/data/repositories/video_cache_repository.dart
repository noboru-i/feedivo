import 'package:sqflite/sqflite.dart';

import '../../domain/entities/video.dart';
import '../../domain/repositories/video_cache_repository_interface.dart';
import '../services/database_service.dart';

/// 動画キャッシュリポジトリ実装
/// SQLiteを使用して動画データをキャッシュ
class VideoCacheRepository implements IVideoCacheRepository {
  @override
  Future<List<Video>> getVideos(String channelId) async {
    final db = await DatabaseService.database;
    final results = await db.query(
      'videos',
      where: 'channel_id = ?',
      whereArgs: [channelId],
      orderBy: 'published_at DESC',
    );

    return results.map(_fromMap).toList();
  }

  @override
  Future<void> saveVideo(Video video) async {
    final db = await DatabaseService.database;
    await db.insert(
      'videos',
      _toMap(video),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveVideos(List<Video> videos) async {
    final db = await DatabaseService.database;
    final batch = db.batch();

    for (final video in videos) {
      batch.insert(
        'videos',
        _toMap(video),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    final db = await DatabaseService.database;
    await db.delete(
      'videos',
      where: 'id = ?',
      whereArgs: [videoId],
    );
  }

  @override
  Future<void> deleteVideosByChannel(String channelId) async {
    final db = await DatabaseService.database;
    await db.delete(
      'videos',
      where: 'channel_id = ?',
      whereArgs: [channelId],
    );
  }

  /// VideoエンティティをMapに変換
  Map<String, dynamic> _toMap(Video video) {
    return {
      'id': video.id,
      'channel_id': video.channelId,
      'title': video.title,
      'description': video.description,
      'video_file_id': video.videoFileId,
      'thumbnail_file_id': video.thumbnailFileId,
      'duration': video.duration,
      'published_at': video.publishedAt.millisecondsSinceEpoch,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// MapからVideoエンティティに変換
  Video _fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'] as String,
      channelId: map['channel_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      videoFileId: map['video_file_id'] as String,
      thumbnailFileId: map['thumbnail_file_id'] as String?,
      duration: map['duration'] as int,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(
        map['published_at'] as int,
      ),
    );
  }
}
