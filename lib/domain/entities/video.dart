/// 動画エンティティ
/// ドメイン層のビジネスロジックで使用する純粋なDartオブジェクト
class Video {
  Video({
    required this.id,
    required this.channelId,
    required this.title,
    required this.description,
    required this.videoFileId,
    this.thumbnailFileId,
    required this.duration,
    required this.publishedAt,
  });
  final String id;
  final String channelId;
  final String title;
  final String description;
  final String videoFileId; // Google Drive File ID
  final String? thumbnailFileId; // Google Drive File ID (オプション)
  final int duration; // 秒数
  final DateTime publishedAt;

  Video copyWith({
    String? id,
    String? channelId,
    String? title,
    String? description,
    String? videoFileId,
    String? thumbnailFileId,
    int? duration,
    DateTime? publishedAt,
  }) {
    return Video(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoFileId: videoFileId ?? this.videoFileId,
      thumbnailFileId: thumbnailFileId ?? this.thumbnailFileId,
      duration: duration ?? this.duration,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Video &&
        other.id == id &&
        other.channelId == channelId &&
        other.title == title &&
        other.description == description &&
        other.videoFileId == videoFileId &&
        other.thumbnailFileId == thumbnailFileId &&
        other.duration == duration &&
        other.publishedAt == publishedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        channelId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        videoFileId.hashCode ^
        (thumbnailFileId?.hashCode ?? 0) ^
        duration.hashCode ^
        publishedAt.hashCode;
  }

  @override
  String toString() {
    return 'Video(id: $id, channelId: $channelId, title: $title, description: $description, videoFileId: $videoFileId, thumbnailFileId: $thumbnailFileId, duration: $duration, publishedAt: $publishedAt)';
  }
}
