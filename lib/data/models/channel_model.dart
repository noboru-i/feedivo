import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/channel.dart';

/// チャンネルモデル
/// FirestoreとDomain Entityの変換を担当
class ChannelModel {
  ChannelModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    this.thumbnailFileId,
    required this.configFileId,
    this.configLastUpdated,
    required this.createdAt,
    required this.updatedAt,
    this.lastFetchedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String description;
  final String? thumbnailFileId;
  final String configFileId;
  final DateTime? configLastUpdated;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastFetchedAt;

  /// FirestoreのDocumentSnapshotからモデルを生成
  factory ChannelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChannelModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      thumbnailFileId: data['thumbnailFileId'] as String?,
      configFileId: data['configFileId'] as String,
      configLastUpdated: (data['configLastUpdated'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastFetchedAt: (data['lastFetchedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firestoreに保存する形式に変換
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'thumbnailFileId': thumbnailFileId,
      'configFileId': configFileId,
      'configLastUpdated': configLastUpdated != null
          ? Timestamp.fromDate(configLastUpdated!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastFetchedAt':
          lastFetchedAt != null ? Timestamp.fromDate(lastFetchedAt!) : null,
    };
  }

  /// Domain Entityに変換
  Channel toEntity() {
    return Channel(
      id: id,
      userId: userId,
      name: name,
      description: description,
      thumbnailFileId: thumbnailFileId,
      configFileId: configFileId,
      configLastUpdated: configLastUpdated,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastFetchedAt: lastFetchedAt,
    );
  }

  /// Domain EntityからModelを生成
  factory ChannelModel.fromEntity(Channel channel) {
    return ChannelModel(
      id: channel.id,
      userId: channel.userId,
      name: channel.name,
      description: channel.description,
      thumbnailFileId: channel.thumbnailFileId,
      configFileId: channel.configFileId,
      configLastUpdated: channel.configLastUpdated,
      createdAt: channel.createdAt,
      updatedAt: channel.updatedAt,
      lastFetchedAt: channel.lastFetchedAt,
    );
  }
}
