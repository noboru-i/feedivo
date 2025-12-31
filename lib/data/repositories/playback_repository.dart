import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/playback_position.dart';
import '../models/playback_position_model.dart';

/// 視聴位置管理のリポジトリ実装
/// Firestoreを使用して視聴位置データを管理
class PlaybackRepository {
  PlaybackRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<void> savePlaybackPosition(
    String userId,
    PlaybackPosition position,
  ) async {
    try {
      final positionModel = PlaybackPositionModel.fromEntity(position);
      final positionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('playback_positions')
          .doc(position.videoId);

      await positionRef.set(positionModel.toFirestore());
    } on Exception {
      rethrow;
    }
  }

  Future<PlaybackPosition?> getPlaybackPosition(
    String userId,
    String videoId,
  ) async {
    try {
      final positionDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('playback_positions')
          .doc(videoId)
          .get();

      if (!positionDoc.exists) {
        return null;
      }

      return PlaybackPositionModel.fromFirestore(positionDoc).toEntity();
    } on Exception {
      rethrow;
    }
  }

  Future<void> markAsCompleted(String userId, String videoId) async {
    try {
      final positionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('playback_positions')
          .doc(videoId);

      await positionRef.update({
        'isCompleted': true,
        'lastPlayedAt': FieldValue.serverTimestamp(),
      });
    } on Exception {
      rethrow;
    }
  }

  Future<List<PlaybackPosition>> getPlaybackHistory(
    String userId, {
    int? limit,
  }) async {
    try {
      var query = _firestore
          .collection('users')
          .doc(userId)
          .collection('playback_positions')
          .orderBy('lastPlayedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => PlaybackPositionModel.fromFirestore(doc).toEntity())
          .toList();
    } on Exception {
      rethrow;
    }
  }

  Future<void> deletePlaybackPositionsByChannel(
    String userId,
    String channelId,
  ) async {
    try {
      final positions = await _firestore
          .collection('users')
          .doc(userId)
          .collection('playback_positions')
          .where('channelId', isEqualTo: channelId)
          .get();

      for (final doc in positions.docs) {
        await doc.reference.delete();
      }
    } on Exception {
      rethrow;
    }
  }
}
