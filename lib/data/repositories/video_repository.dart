import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository_interface.dart';
import '../models/video_model.dart';

/// 動画管理のリポジトリ実装
/// Firestoreを使用して動画データを管理
class VideoRepository implements IVideoRepository {
  VideoRepository({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  /// 現在のユーザーIDを取得
  String get _currentUserId {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return userId;
  }

  @override
  Future<List<Video>> getVideos(String channelId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('channels')
          .doc(channelId)
          .collection('videos')
          .orderBy('publishedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => VideoModel.fromFirestore(doc).toEntity())
          .toList();
    } on Exception {
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
      final videoModel = VideoModel.fromEntity(video);
      final videoRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('channels')
          .doc(video.channelId)
          .collection('videos')
          .doc(video.id);

      await videoRef.set(videoModel.toFirestore());
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
      // 既存の動画IDリストを取得
      final existingVideos = await _firestore
          .collection('users')
          .doc(_currentUserId)
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
            .doc(_currentUserId)
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
      final videos = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('channels')
          .doc(channelId)
          .collection('videos')
          .get();

      for (final doc in videos.docs) {
        await doc.reference.delete();
      }
    } on Exception {
      rethrow;
    }
  }
}
