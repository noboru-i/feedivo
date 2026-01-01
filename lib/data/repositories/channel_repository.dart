import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/channel.dart';
import '../models/channel_config_model.dart';
import '../models/channel_model.dart';
import 'google_drive_repository.dart';
import 'video_repository.dart';

/// チャンネル管理のリポジトリ実装
/// Google DriveとFirestoreを連携してチャンネルを管理
/// Firestoreのネイティブオフライン永続化を使用
class ChannelRepository {
  ChannelRepository({
    required FirebaseFirestore firestore,
    required GoogleDriveRepository driveRepo,
    required VideoRepository videoRepo,
  }) : _firestore = firestore,
       _driveRepo = driveRepo,
       _videoRepo = videoRepo;

  final FirebaseFirestore _firestore;
  final GoogleDriveRepository _driveRepo;
  final VideoRepository _videoRepo;

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

  Future<Channel?> getChannel(String userId, String channelId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .doc(channelId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return ChannelModel.fromFirestore(doc).toEntity();
    } on Exception catch (e) {
      throw FirestoreException('チャンネルの取得に失敗しました: $e');
    }
  }

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

      // 動画リストを同期（videosが空の場合はmp4ファイルを自動検出）
      await _syncVideos(userId, config.channelInfo.id, config.videos, fileId);

      return channelModel.toEntity();
    } on InvalidConfigException {
      rethrow;
    } on DriveApiException {
      rethrow;
    } on Exception catch (e) {
      throw FirestoreException('チャンネルの追加に失敗しました: $e');
    }
  }

  Future<void> deleteChannel(String userId, String channelId) async {
    try {
      // サブコレクション（videos）を削除
      await _videoRepo.deleteVideosByChannel(channelId);

      // チャンネルドキュメントを削除
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .doc(channelId)
          .delete();
    } on Exception catch (e) {
      throw FirestoreException('チャンネルの削除に失敗しました: $e');
    }
  }

  Future<Channel> refreshChannel(String userId, String channelId) async {
    try {
      // 既存のチャンネル情報を取得
      final channelDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .doc(channelId)
          .get();

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

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('channels')
            .doc(channelId)
            .update({
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

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .doc(channelId)
          .update(updatedModel.toFirestore());

      // 動画リストを同期（videosが空の場合はmp4ファイルを自動検出）
      await _syncVideos(
        channelModel.userId,
        channelModel.id,
        config.videos,
        channelModel.configFileId,
      );

      return updatedModel.toEntity();
    } on InvalidConfigException {
      rethrow;
    } on DriveApiException {
      rethrow;
    } on Exception catch (e) {
      throw FirestoreException('チャンネルの更新に失敗しました: $e');
    }
  }

  /// 動画リストを同期する
  /// videosが空の場合は、設定ファイルと同じフォルダ内のmp4ファイルを自動検出
  Future<void> _syncVideos(
    String userId,
    String channelId,
    List<VideoInfoModel> videos,
    String configFileId,
  ) async {
    var videoList = videos;

    // videosが空の場合は、mp4ファイルを自動検出
    if (videoList.isEmpty) {
      videoList = await _autoDetectMp4Files(configFileId);
    }

    // VideoRepositoryを使用して動画を同期
    await _videoRepo.syncVideosFromConfig(
      channelId,
      videoList.map((v) => v.toJson()).toList(),
    );
  }

  /// 設定ファイルと同じフォルダ内のmp4ファイルを自動検出
  Future<List<VideoInfoModel>> _autoDetectMp4Files(String configFileId) async {
    try {
      // 設定ファイルのメタデータを取得して親フォルダIDを取得
      final metadata = await _driveRepo.getFileMetadata(configFileId);
      final parents = metadata['parents'] as List<dynamic>?;

      if (parents == null || parents.isEmpty) {
        // 親フォルダがない場合は空リストを返す
        return [];
      }

      final folderId = parents.first as String;

      // フォルダ内のmp4ファイル一覧を取得
      final files = await _driveRepo.listFilesInFolder(
        folderId,
        mimeTypeFilter: 'video/mp4',
      );

      // 各mp4ファイルから動画情報を生成
      final videos = <VideoInfoModel>[];
      for (final file in files) {
        final fileId = file['id'] as String;
        final fileName = file['name'] as String;
        final createdTime = file['createdTime'] as String?;
        final modifiedTime = file['modifiedTime'] as String?;

        // ファイル名から拡張子を除去してタイトルを生成
        final title = fileName.replaceAll(RegExp(r'\.mp4$'), '');

        videos.add(
          VideoInfoModel(
            id: fileId,
            title: title,
            description: fileName,
            videoFileId: fileId,
            duration: 0, // durationは再生時に取得される
            publishedAt: createdTime != null
                ? DateTime.parse(createdTime)
                : (modifiedTime != null
                      ? DateTime.parse(modifiedTime)
                      : DateTime.now()),
          ),
        );
      }

      return videos;
    } on Exception {
      // エラーが発生した場合は空リストを返す
      return [];
    }
  }
}
