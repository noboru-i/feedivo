/// チャンネルエンティティ
/// ドメイン層のビジネスロジックで使用する純粋なDartオブジェクト
class Channel {
  Channel({
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
  final String? thumbnailFileId; // Google Drive File ID
  final String configFileId; // 設定ファイルのGoogle Drive File ID
  final DateTime? configLastUpdated; // 設定ファイルの最終更新日時
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastFetchedAt; // 最後にDriveから取得した日時

  Channel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? thumbnailFileId,
    String? configFileId,
    DateTime? configLastUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastFetchedAt,
  }) {
    return Channel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnailFileId: thumbnailFileId ?? this.thumbnailFileId,
      configFileId: configFileId ?? this.configFileId,
      configLastUpdated: configLastUpdated ?? this.configLastUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Channel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.description == description &&
        other.thumbnailFileId == thumbnailFileId &&
        other.configFileId == configFileId &&
        other.configLastUpdated == configLastUpdated &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastFetchedAt == lastFetchedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        (thumbnailFileId?.hashCode ?? 0) ^
        configFileId.hashCode ^
        (configLastUpdated?.hashCode ?? 0) ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        (lastFetchedAt?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'Channel(id: $id, userId: $userId, name: $name, description: $description, thumbnailFileId: $thumbnailFileId, configFileId: $configFileId, configLastUpdated: $configLastUpdated, createdAt: $createdAt, updatedAt: $updatedAt, lastFetchedAt: $lastFetchedAt)';
  }
}
