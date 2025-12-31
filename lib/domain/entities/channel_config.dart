/// チャンネル設定ファイル構造エンティティ
/// JSONからパースされたチャンネル設定情報
class ChannelConfig {
  ChannelConfig({
    required this.version,
    required this.channelInfo,
    required this.videos,
  });
  final String version;
  final ChannelInfo channelInfo;
  final List<VideoInfo> videos;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ChannelConfig &&
        other.version == version &&
        other.channelInfo == channelInfo &&
        _listEquals(other.videos, videos);
  }

  @override
  int get hashCode {
    return version.hashCode ^ channelInfo.hashCode ^ _listHashCode(videos);
  }

  @override
  String toString() {
    return 'ChannelConfig(version: $version, channelInfo: $channelInfo, videos: $videos)';
  }

  // リスト比較用ヘルパー
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  int _listHashCode<T>(List<T>? list) {
    if (list == null) {
      return 0;
    }
    var hash = 0;
    for (final item in list) {
      hash ^= item.hashCode;
    }
    return hash;
  }
}

/// チャンネル情報（設定ファイル内）
class ChannelInfo {
  ChannelInfo({
    required this.id,
    required this.name,
    required this.description,
    this.thumbnailFileId,
    required this.updatedAt,
  });
  final String id;
  final String name;
  final String description;
  final String? thumbnailFileId;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ChannelInfo &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.thumbnailFileId == thumbnailFileId &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        (thumbnailFileId?.hashCode ?? 0) ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ChannelInfo(id: $id, name: $name, description: $description, thumbnailFileId: $thumbnailFileId, updatedAt: $updatedAt)';
  }
}

/// 動画情報（設定ファイル内）
class VideoInfo {
  VideoInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.videoFileId,
    this.thumbnailFileId,
    required this.duration,
    required this.publishedAt,
  });
  final String id;
  final String title;
  final String description;
  final String videoFileId;
  final String? thumbnailFileId;
  final int duration;
  final DateTime publishedAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is VideoInfo &&
        other.id == id &&
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
        title.hashCode ^
        description.hashCode ^
        videoFileId.hashCode ^
        (thumbnailFileId?.hashCode ?? 0) ^
        duration.hashCode ^
        publishedAt.hashCode;
  }

  @override
  String toString() {
    return 'VideoInfo(id: $id, title: $title, description: $description, videoFileId: $videoFileId, thumbnailFileId: $thumbnailFileId, duration: $duration, publishedAt: $publishedAt)';
  }
}
