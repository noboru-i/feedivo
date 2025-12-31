import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/video.dart';
import '../../domain/repositories/video_cache_repository_interface.dart';
import '../../domain/repositories/video_repository_interface.dart';
import '../models/video_model.dart';

/// 動画管理のリポジトリ実装
/// Firestoreを使用して動画データを管理
class VideoRepository implements IVideoRepository {
  VideoRepository({
    required FirebaseFirestore firestore,
    required IVideoCacheRepository cacheRepo,
  }) : _firestore = firestore,
       _cacheRepo = cacheRepo;

  final FirebaseFirestore _firestore;
  final IVideoCacheRepository _cacheRepo;

  @override
  Future<List<Video>> getVideos(String channelId) async {
    try {
      // まずチャンネルドキュメントからuserIdを取得
      final channelQuerySnapshot = await _firestore
          .collectionGroup('channels')
          .where('id', isEqualTo: channelId)
          .limit(1)
          .get();

      if (channelQuerySnapshot.docs.isEmpty) {
        return [];
      }

      final channelDoc = channelQuerySnapshot.docs.first;
      final channelData = channelDoc.data();
      final userId = channelData['userId'] as String;

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .doc(channelId)
          .collection('videos')
          .orderBy('publishedAt', descending: true)
          .get();

      final videos = querySnapshot.docs
          .map((doc) => VideoModel.fromFirestore(doc).toEntity())
          .toList();

      // キャッシュに保存
      await _cacheRepo.saveVideos(videos);

      return videos;
    } on Exception {
      // オフライン時はキャッシュから取得
      try {
        final cachedVideos = await _cacheRepo.getVideos(channelId);
        if (cachedVideos.isNotEmpty) {
          return cachedVideos;
        }
      } on Exception {
        // キャッシュも失敗した場合は元のエラーをスロー
      }
      rethrow;
    }
  }

  @override
  Future<Video?> getVideo(String videoId) async {
    try {
      // collectionGroupを使用してvideoIdで検索
      final videoQuerySnapshot = await _firestore
          .collectionGroup('videos')
          .where('id', isEqualTo: videoId)
          .limit(1)
          .get();

      if (videoQuerySnapshot.docs.isEmpty) {
        return null;
      }

      return VideoModel.fromFirestore(videoQuerySnapshot.docs.first).toEntity();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> saveVideo(Video video) async {
    try {
      // channelIdからuserIdを取得
      final channelQuerySnapshot = await _firestore
          .collectionGroup('channels')
          .where('id', isEqualTo: video.channelId)
          .limit(1)
          .get();

      if (channelQuerySnapshot.docs.isEmpty) {
        throw Exception('Channel not found: ${video.channelId}');
      }

      final channelData = channelQuerySnapshot.docs.first.data();
      final userId = channelData['userId'] as String;

      final videoModel = VideoModel.fromEntity(video);
      final videoRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .doc(video.channelId)
          .collection('videos')
          .doc(video.id);

      await videoRef.set(videoModel.toFirestore());

      // キャッシュに保存
      await _cacheRepo.saveVideo(video);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> syncVideosFromConfig(
    String channelId,
    List<dynamic> videos,
  ) async {
    try {
      // チャンネル情報を取得
      final channelQuerySnapshot = await _firestore
          .collectionGroup('channels')
          .where('id', isEqualTo: channelId)
          .limit(1)
          .get();

      if (channelQuerySnapshot.docs.isEmpty) {
        throw Exception('Channel not found: $channelId');
      }

      final channelData = channelQuerySnapshot.docs.first.data();
      final userId = channelData['userId'] as String;

      // 既存の動画IDリストを取得
      final existingVideos = await _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .doc(channelId)
          .collection('videos')
          .get();

      final existingVideoIds = existingVideos.docs.map((doc) => doc.id).toSet();

      // 設定ファイルからの動画IDリスト
      final configVideoIds = videos
          .map((v) => (v as Map<String, dynamic>)['id'] as String)
          .toSet();

      // 削除すべき動画（設定ファイルに存在しない）
      final videosToDelete = existingVideoIds.difference(configVideoIds);

      // 削除処理
      for (final videoId in videosToDelete) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('channels')
            .doc(channelId)
            .collection('videos')
            .doc(videoId)
            .delete();
      }

      // 追加・更新処理
      for (final videoData in videos) {
        final videoInfo = videoData as Map<String, dynamic>;
        final videoId = videoInfo['id'] as String;

        final video = Video(
          id: videoId,
          channelId: channelId,
          title: videoInfo['title'] as String,
          description: videoInfo['description'] as String,
          videoFileId: videoInfo['video_file_id'] as String,
          thumbnailFileId: videoInfo['thumbnail_file_id'] as String?,
          duration: videoInfo['duration'] as int,
          publishedAt: DateTime.parse(videoInfo['published_at'] as String),
        );

        await saveVideo(video);
      }
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> deleteVideosByChannel(String channelId) async {
    try {
      // チャンネル情報を取得
      final channelQuerySnapshot = await _firestore
          .collectionGroup('channels')
          .where('id', isEqualTo: channelId)
          .limit(1)
          .get();

      if (channelQuerySnapshot.docs.isEmpty) {
        return;
      }

      final channelData = channelQuerySnapshot.docs.first.data();
      final userId = channelData['userId'] as String;

      final videos = await _firestore
          .collection('users')
          .doc(userId)
          .collection('channels')
          .doc(channelId)
          .collection('videos')
          .get();

      for (final doc in videos.docs) {
        await doc.reference.delete();
      }

      // キャッシュから削除
      await _cacheRepo.deleteVideosByChannel(channelId);
    } on Exception {
      rethrow;
    }
  }
}
