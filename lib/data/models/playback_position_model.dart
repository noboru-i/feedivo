import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/playback_position.dart';

/// 視聴位置モデル
/// FirestoreとDomain Entityの変換を担当
class PlaybackPositionModel {
  PlaybackPositionModel({
    required this.videoId,
    required this.channelId,
    required this.position,
    required this.duration,
    required this.lastPlayedAt,
    required this.isCompleted,
  });

  /// FirestoreのDocumentSnapshotからモデルを生成
  factory PlaybackPositionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;

    return PlaybackPositionModel(
      videoId: doc.id,
      channelId: data['channelId'] as String,
      position: data['position'] as int,
      duration: data['duration'] as int,
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] as bool,
    );
  }

  /// Domain EntityからModelを生成
  factory PlaybackPositionModel.fromEntity(PlaybackPosition position) {
    return PlaybackPositionModel(
      videoId: position.videoId,
      channelId: position.channelId,
      position: position.position,
      duration: position.duration,
      lastPlayedAt: position.lastPlayedAt,
      isCompleted: position.isCompleted,
    );
  }

  final String videoId;
  final String channelId;
  final int position;
  final int duration;
  final DateTime lastPlayedAt;
  final bool isCompleted;

  /// Firestoreに保存する形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'channelId': channelId,
      'position': position,
      'duration': duration,
      'lastPlayedAt': Timestamp.fromDate(lastPlayedAt),
      'isCompleted': isCompleted,
      'watchPercentage': duration > 0 ? position / duration : 0,
    };
  }

  /// Domain Entityに変換
  PlaybackPosition toEntity() {
    return PlaybackPosition(
      videoId: videoId,
      channelId: channelId,
      position: position,
      duration: duration,
      lastPlayedAt: lastPlayedAt,
      isCompleted: isCompleted,
    );
  }
}
