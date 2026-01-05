import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/video.dart';

/// 動画モデル
/// FirestoreとDomain Entityの変換を担当
class VideoModel {
  VideoModel({
    required this.id,
    required this.channelId,
    required this.title,
    required this.description,
    required this.videoFileId,
    this.thumbnailFileId,
    required this.duration,
    required this.publishedAt,
    this.lastViewedAt,
  });

  /// FirestoreのDocumentSnapshotからモデルを生成
  factory VideoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;

    return VideoModel(
      id: doc.id,
      channelId: data['channelId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      videoFileId: data['videoFileId'] as String,
      thumbnailFileId: data['thumbnailFileId'] as String?,
      duration: data['duration'] as int,
      publishedAt: (data['publishedAt'] as Timestamp).toDate(),
      lastViewedAt: data['lastViewedAt'] != null
          ? (data['lastViewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Domain EntityからModelを生成
  factory VideoModel.fromEntity(Video video) {
    return VideoModel(
      id: video.id,
      channelId: video.channelId,
      title: video.title,
      description: video.description,
      videoFileId: video.videoFileId,
      thumbnailFileId: video.thumbnailFileId,
      duration: video.duration,
      publishedAt: video.publishedAt,
      lastViewedAt: video.lastViewedAt,
    );
  }

  final String id;
  final String channelId;
  final String title;
  final String description;
  final String videoFileId;
  final String? thumbnailFileId;
  final int duration;
  final DateTime publishedAt;
  final DateTime? lastViewedAt;

  /// Firestoreに保存する形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'channelId': channelId,
      'title': title,
      'description': description,
      'videoFileId': videoFileId,
      'thumbnailFileId': thumbnailFileId,
      'duration': duration,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'lastViewedAt': lastViewedAt != null
          ? Timestamp.fromDate(lastViewedAt!)
          : null,
    };
  }

  /// Domain Entityに変換
  Video toEntity() {
    return Video(
      id: id,
      channelId: channelId,
      title: title,
      description: description,
      videoFileId: videoFileId,
      thumbnailFileId: thumbnailFileId,
      duration: duration,
      publishedAt: publishedAt,
      lastViewedAt: lastViewedAt,
    );
  }
}
