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

      // フォルダかファイルかを判別
      final isFolder = await _driveRepo.isFolder(fileId);

      if (isFolder) {
        // フォルダの場合の処理（新規フロー）
        return await _addChannelFromFolder(userId, fileId);
      } else {
        // ファイルの場合の処理（既存フロー）
        return await _addChannelFromFile(userId, fileId);
      }
    } on InvalidConfigException {
      rethrow;
    } on DriveApiException {
      rethrow;
    } on Exception catch (e) {
      throw FirestoreException('チャンネルの追加に失敗しました: $e');
    }
  }

  /// ファイルからチャンネル追加（既存のaddChannelの中身）
  Future<Channel> _addChannelFromFile(String userId, String fileId) async {
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

    // 動画リストを同期（videosが空の場合は動画ファイルを自動検出）
    await _syncVideos(userId, config.channelInfo.id, config.videos, fileId);

    return channelModel.toEntity();
  }

  /// フォルダからチャンネル追加
  Future<Channel> _addChannelFromFolder(String userId, String folderId) async {
    // フォルダ内のchannel_config.jsonを検索
    final configFile = await _findChannelConfig(folderId);

    if (configFile != null) {
      // JSONファイルがある場合: 既存フローで処理
      return _addChannelFromFile(userId, configFile['id'] as String);
    } else {
      // JSONファイルがない場合: 自動生成フロー
      return _addChannelFromFolderAutoGenerate(userId, folderId);
    }
  }

  /// channel_config.jsonを検索
  Future<Map<String, dynamic>?> _findChannelConfig(String folderId) async {
    final files = await _driveRepo.listFilesInFolder(folderId);

    for (final file in files) {
      final name = file['name'] as String?;
      if (name == 'channel_config.json') {
        return file;
      }
    }

    return null;
  }

  /// フォルダから自動生成
  Future<Channel> _addChannelFromFolderAutoGenerate(
    String userId,
    String folderId,
  ) async {
    // フォルダ名を取得してチャンネル名として使用
    final folderName = await _driveRepo.getFolderName(folderId);

    // チャンネルIDを生成（フォルダIDを使用）
    final channelId = 'folder_$folderId';

    // フォルダ内の動画ファイルを検出（拡張版）
    final videos = await _autoDetectVideoFilesInFolder(folderId);

    if (videos.isEmpty) {
      throw InvalidConfigException(
        'フォルダ内に動画ファイルが見つかりませんでした。',
      );
    }

    // チャンネル情報を作成
    final now = DateTime.now();
    final channelRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('channels')
        .doc(channelId);

    final channelModel = ChannelModel(
      id: channelId,
      userId: userId,
      name: folderName,
      description: 'フォルダから自動生成されたチャンネル',
      configFileId: folderId, // フォルダIDを保存
      configLastUpdated: now,
      createdAt: now,
      updatedAt: now,
      lastFetchedAt: now,
    );

    // Firestoreに保存
    await channelRef.set(channelModel.toFirestore());

    // 動画リストを同期
    await _syncVideos(userId, channelId, videos, folderId);

    return channelModel.toEntity();
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

      // configFileIdがフォルダかファイルかを判別
      final isFolder = await _driveRepo.isFolder(channelModel.configFileId);

      if (isFolder) {
        // フォルダベースのチャンネル更新
        return _refreshChannelFromFolder(userId, channelId, channelModel);
      } else {
        // ファイルベースのチャンネル更新（既存処理）
        return _refreshChannelFromFile(userId, channelId, channelModel);
      }
    } on InvalidConfigException {
      rethrow;
    } on DriveApiException {
      rethrow;
    } on Exception catch (e) {
      throw FirestoreException('チャンネルの更新に失敗しました: $e');
    }
  }

  /// ファイルベースチャンネルの更新（既存処理）
  Future<Channel> _refreshChannelFromFile(
    String userId,
    String channelId,
    ChannelModel channelModel,
  ) async {
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
      final updatedModel = channelModel.copyWith(
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
    final updatedModel = channelModel.copyWith(
      name: config.channelInfo.name,
      description: config.channelInfo.description,
      thumbnailFileId: config.channelInfo.thumbnailFileId,
      configLastUpdated: config.channelInfo.updatedAt,
      updatedAt: now,
      lastFetchedAt: now,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('channels')
        .doc(channelId)
        .update(updatedModel.toFirestore());

    // 動画リストを同期（videosが空の場合は動画ファイルを自動検出）
    await _syncVideos(
      channelModel.userId,
      channelModel.id,
      config.videos,
      channelModel.configFileId,
    );

    return updatedModel.toEntity();
  }

  /// フォルダベースチャンネルの更新
  Future<Channel> _refreshChannelFromFolder(
    String userId,
    String channelId,
    ChannelModel channelModel,
  ) async {
    // フォルダ内のchannel_config.jsonを検索
    final configFile = await _findChannelConfig(channelModel.configFileId);

    if (configFile != null) {
      // JSONファイルがある場合: ファイルベース更新に移行
      final updatedModel = channelModel.copyWith(
        configFileId: configFile['id'] as String,
      );

      // JSONファイルベースの更新を実行
      return _refreshChannelFromFile(userId, channelId, updatedModel);
    } else {
      // JSONファイルがない場合: 動画リストを再取得
      final videos = await _autoDetectVideoFilesInFolder(
        channelModel.configFileId,
      );

      if (videos.isEmpty) {
        throw InvalidConfigException(
          'フォルダ内に動画ファイルが見つかりませんでした。',
        );
      }

      // 動画リストを同期
      await _syncVideos(
        userId,
        channelId,
        videos,
        channelModel.configFileId,
      );

      // lastFetchedAtを更新
      final now = DateTime.now();
      final updatedModel = channelModel.copyWith(
        lastFetchedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .doc(channelId)
          .update({
            'lastFetchedAt': Timestamp.fromDate(now),
          });

      return updatedModel.toEntity();
    }
  }

  /// 動画リストを同期する
  /// videosが空の場合は、設定ファイルと同じフォルダ内の動画ファイルを自動検出
  Future<void> _syncVideos(
    String userId,
    String channelId,
    List<VideoInfoModel> videos,
    String configFileId,
  ) async {
    var videoList = videos;

    // videosが空の場合は、動画ファイルを自動検出
    if (videoList.isEmpty) {
      videoList = await _autoDetectVideoFiles(configFileId);
    }

    // VideoRepositoryを使用して動画を同期
    await _videoRepo.syncVideosFromConfig(
      channelId,
      videoList.map((v) => v.toJson()).toList(),
    );
  }

  /// 設定ファイルと同じフォルダ内の動画ファイルを自動検出（複数形式対応）
  Future<List<VideoInfoModel>> _autoDetectVideoFiles(
    String configFileId,
  ) async {
    try {
      // 設定ファイルのメタデータを取得して親フォルダIDを取得
      final metadata = await _driveRepo.getFileMetadata(configFileId);
      final parents = metadata['parents'] as List<dynamic>?;

      if (parents == null || parents.isEmpty) {
        // 親フォルダがない場合は空リストを返す
        return [];
      }

      final folderId = parents.first as String;

      return await _autoDetectVideoFilesInFolder(folderId);
    } on Exception {
      // エラーが発生した場合は空リストを返す
      return [];
    }
  }

  /// フォルダ内の動画ファイルを自動検出（複数形式対応）
  Future<List<VideoInfoModel>> _autoDetectVideoFilesInFolder(
    String folderId,
  ) async {
    try {
      // サポートする動画形式のリスト
      const supportedVideoTypes = [
        'video/mp4',
        'video/webm',
        'video/quicktime', // .mov
        'video/x-msvideo', // .avi
        'video/x-matroska', // .mkv
      ];

      final allVideos = <VideoInfoModel>[];

      // 各形式ごとにファイルを検索
      for (final mimeType in supportedVideoTypes) {
        final files = await _driveRepo.listFilesInFolder(
          folderId,
          mimeTypeFilter: mimeType,
        );

        // 各動画ファイルから動画情報を生成
        for (final file in files) {
          final fileId = file['id'] as String;
          final fileName = file['name'] as String;
          final createdTime = file['createdTime'] as String?;
          final modifiedTime = file['modifiedTime'] as String?;

          // ファイル名から拡張子を除去してタイトルを生成
          final title = fileName.replaceAll(
            RegExp(r'\.(mp4|webm|mov|avi|mkv)$', caseSensitive: false),
            '',
          );

          allVideos.add(
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
      }

      // createdTimeでソート（古い順）
      allVideos.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));

      return allVideos;
    } on Exception {
      // エラーが発生した場合は空リストを返す
      return [];
    }
  }
}
