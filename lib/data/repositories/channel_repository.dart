import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/channel.dart';
import '../../domain/repositories/channel_repository_interface.dart';
import '../../domain/repositories/google_drive_repository_interface.dart';
import '../models/channel_config_model.dart';
import '../models/channel_model.dart';

/// チャンネル管理のリポジトリ実装
/// Google DriveとFirestoreを連携してチャンネルを管理
class ChannelRepository implements IChannelRepository {
  ChannelRepository({
    required FirebaseFirestore firestore,
    required IGoogleDriveRepository driveRepo,
  }) : _firestore = firestore,
       _driveRepo = driveRepo;

  final FirebaseFirestore _firestore;
  final IGoogleDriveRepository _driveRepo;

  @override
  Future<List<Channel>> getChannels(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ChannelModel.fromFirestore(doc).toEntity())
          .toList();
    } on Exception catch (e) {
      throw FirestoreException('チャンネル一覧の取得に失敗しました: $e');
    }
  }

  @override
  Future<Channel?> getChannel(String channelId) async {
    try {
      // channelIdからuserIdを抽出（形式: users/{userId}/channels/{channelId}）
      final doc = await _firestore.doc(channelId).get();

      if (!doc.exists) {
        return null;
      }

      return ChannelModel.fromFirestore(doc).toEntity();
    } on Exception catch (e) {
      throw FirestoreException('チャンネルの取得に失敗しました: $e');
    }
  }

  @override
  Future<Channel> addChannel(String userId, String configFileId) async {
    try {
      // File IDを抽出（URLの場合）
      final fileId = _driveRepo.extractFileId(configFileId);

      // Google Driveから設定ファイルを取得
      final configJson = await _driveRepo.downloadFileAsString(fileId);

      // JSONをパース
      final configData = json.decode(configJson) as Map<String, dynamic>;
      final config = ChannelConfigModel.fromJson(configData);

      // チャンネル情報を作成
      final now = DateTime.now();
      final channelRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .doc(config.channelInfo.id);

      final channelModel = ChannelModel(
        id: config.channelInfo.id,
        userId: userId,
        name: config.channelInfo.name,
        description: config.channelInfo.description,
        thumbnailFileId: config.channelInfo.thumbnailFileId,
        configFileId: fileId,
        configLastUpdated: config.channelInfo.updatedAt,
        createdAt: now,
        updatedAt: now,
        lastFetchedAt: now,
      );

      // Firestoreに保存
      await channelRef.set(channelModel.toFirestore());

      return channelModel.toEntity();
    } on InvalidConfigException {
      rethrow;
    } on DriveApiException {
      rethrow;
    } on Exception catch (e) {
      throw FirestoreException('チャンネルの追加に失敗しました: $e');
    }
  }

  @override
  Future<void> deleteChannel(String channelId) async {
    try {
      await _firestore.doc(channelId).delete();

      // TODO: サブコレクション（videos）の削除も必要
      // Phase 2-3で実装予定
    } on Exception catch (e) {
      throw FirestoreException('チャンネルの削除に失敗しました: $e');
    }
  }

  @override
  Future<Channel> refreshChannel(String channelId) async {
    try {
      // 既存のチャンネル情報を取得
      final channelDoc = await _firestore.doc(channelId).get();

      if (!channelDoc.exists) {
        throw FirestoreException('チャンネルが見つかりません');
      }

      final channelModel = ChannelModel.fromFirestore(channelDoc);

      // Google Driveから最新の設定ファイルを取得
      final configJson = await _driveRepo.downloadFileAsString(
        channelModel.configFileId,
      );

      // JSONをパース
      final configData = json.decode(configJson) as Map<String, dynamic>;
      final config = ChannelConfigModel.fromJson(configData);

      // 更新日時をチェック
      final hasUpdate =
          channelModel.configLastUpdated == null ||
          config.channelInfo.updatedAt.isAfter(channelModel.configLastUpdated!);

      if (!hasUpdate) {
        // 更新がない場合はlastFetchedAtだけ更新
        final updatedModel = ChannelModel(
          id: channelModel.id,
          userId: channelModel.userId,
          name: channelModel.name,
          description: channelModel.description,
          thumbnailFileId: channelModel.thumbnailFileId,
          configFileId: channelModel.configFileId,
          configLastUpdated: channelModel.configLastUpdated,
          createdAt: channelModel.createdAt,
          updatedAt: channelModel.updatedAt,
          lastFetchedAt: DateTime.now(),
        );

        await _firestore.doc(channelId).update({
          'lastFetchedAt': Timestamp.fromDate(updatedModel.lastFetchedAt!),
        });

        return updatedModel.toEntity();
      }

      // 更新がある場合は全情報を更新
      final now = DateTime.now();
      final updatedModel = ChannelModel(
        id: channelModel.id,
        userId: channelModel.userId,
        name: config.channelInfo.name,
        description: config.channelInfo.description,
        thumbnailFileId: config.channelInfo.thumbnailFileId,
        configFileId: channelModel.configFileId,
        configLastUpdated: config.channelInfo.updatedAt,
        createdAt: channelModel.createdAt,
        updatedAt: now,
        lastFetchedAt: now,
      );

      await _firestore.doc(channelId).update(updatedModel.toFirestore());

      return updatedModel.toEntity();
    } on InvalidConfigException {
      rethrow;
    } on DriveApiException {
      rethrow;
    } on Exception catch (e) {
      throw FirestoreException('チャンネルの更新に失敗しました: $e');
    }
  }
}
