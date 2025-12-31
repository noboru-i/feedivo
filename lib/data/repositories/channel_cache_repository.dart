import 'package:sqflite/sqflite.dart';

import '../../domain/entities/channel.dart';
import '../../domain/repositories/channel_cache_repository_interface.dart';
import '../services/database_service.dart';

/// チャンネルキャッシュリポジトリ実装
/// SQLiteを使用してチャンネルデータをキャッシュ
class ChannelCacheRepository implements IChannelCacheRepository {
  @override
  Future<List<Channel>> getChannels(String userId) async {
    final db = await DatabaseService.database;
    final results = await db.query(
      'channels',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    return results.map(_fromMap).toList();
  }

  @override
  Future<void> saveChannel(Channel channel) async {
    final db = await DatabaseService.database;
    await db.insert(
      'channels',
      _toMap(channel),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveChannels(List<Channel> channels) async {
    final db = await DatabaseService.database;
    final batch = db.batch();

    for (final channel in channels) {
      batch.insert(
        'channels',
        _toMap(channel),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteChannel(String channelId) async {
    final db = await DatabaseService.database;
    await db.delete(
      'channels',
      where: 'id = ?',
      whereArgs: [channelId],
    );
  }

  @override
  Future<void> deleteChannelsByUser(String userId) async {
    final db = await DatabaseService.database;
    await db.delete(
      'channels',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// ChannelエンティティをMapに変換
  Map<String, dynamic> _toMap(Channel channel) {
    return {
      'id': channel.id,
      'user_id': channel.userId,
      'name': channel.name,
      'description': channel.description,
      'thumbnail_file_id': channel.thumbnailFileId,
      'config_file_id': channel.configFileId,
      'updated_at': channel.updatedAt.millisecondsSinceEpoch,
      'synced_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// MapからChannelエンティティに変換
  Channel _fromMap(Map<String, dynamic> map) {
    final updatedAt =
        DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int);
    return Channel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      thumbnailFileId: map['thumbnail_file_id'] as String?,
      configFileId: map['config_file_id'] as String,
      createdAt: updatedAt, // キャッシュではcreatedAtは保存しないためupdatedAtを使用
      updatedAt: updatedAt,
    );
  }
}
