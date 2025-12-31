import '../../core/errors/exceptions.dart';
import '../../domain/entities/channel_config.dart';

/// チャンネル設定ファイルモデル
/// JSONとDomain Entityの変換を担当
class ChannelConfigModel {
  ChannelConfigModel({
    required this.version,
    required this.channelInfo,
    required this.videos,
  });

  /// JSONからモデルを生成（バリデーション含む）
  factory ChannelConfigModel.fromJson(Map<String, dynamic> json) {
    // バージョンチェック
    final version = json['version'] as String?;
    if (version == null || version.isEmpty) {
      throw InvalidConfigException('バージョン情報が見つかりません');
    }

    if (version != '1.0') {
      throw InvalidConfigException('サポートされていないバージョンです: $version');
    }

    // チャンネル情報のバリデーション
    final channelData = json['channel'] as Map<String, dynamic>?;
    if (channelData == null) {
      throw InvalidConfigException('チャンネル情報が見つかりません');
    }

    // 動画リストのバリデーション
    final videosData = json['videos'] as List<dynamic>?;
    if (videosData == null) {
      throw InvalidConfigException('動画リストが見つかりません');
    }

    try {
      return ChannelConfigModel(
        version: version,
        channelInfo: ChannelInfoModel.fromJson(channelData),
        videos: videosData
            .map((v) => VideoInfoModel.fromJson(v as Map<String, dynamic>))
            .toList(),
      );
    } on Exception catch (e) {
      throw InvalidConfigException('設定ファイルの形式が正しくありません: $e');
    }
  }

  final String version;
  final ChannelInfoModel channelInfo;
  final List<VideoInfoModel> videos;

  /// Domain Entityに変換
  ChannelConfig toEntity() {
    return ChannelConfig(
      version: version,
      channelInfo: channelInfo.toEntity(),
      videos: videos.map((v) => v.toEntity()).toList(),
    );
  }
}

/// チャンネル情報モデル（設定ファイル内）
class ChannelInfoModel {
  ChannelInfoModel({
    required this.id,
    required this.name,
    required this.description,
    this.thumbnailFileId,
    required this.updatedAt,
  });

  factory ChannelInfoModel.fromJson(Map<String, dynamic> json) {
    // 必須フィールドのバリデーション
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    final description = json['description'] as String?;
    final updatedAtStr = json['updated_at'] as String?;

    if (id == null || id.isEmpty) {
      throw InvalidConfigException('チャンネルIDが見つかりません');
    }
    if (name == null || name.isEmpty) {
      throw InvalidConfigException('チャンネル名が見つかりません');
    }
    if (description == null) {
      throw InvalidConfigException('チャンネル説明が見つかりません');
    }
    if (updatedAtStr == null) {
      throw InvalidConfigException('更新日時が見つかりません');
    }

    // 日時のパース
    DateTime updatedAt;
    try {
      updatedAt = DateTime.parse(updatedAtStr);
    } on Exception {
      throw InvalidConfigException('更新日時の形式が正しくありません: $updatedAtStr');
    }

    return ChannelInfoModel(
      id: id,
      name: name,
      description: description,
      thumbnailFileId: json['thumbnail_file_id'] as String?,
      updatedAt: updatedAt,
    );
  }

  final String id;
  final String name;
  final String description;
  final String? thumbnailFileId;
  final DateTime updatedAt;

  ChannelInfo toEntity() {
    return ChannelInfo(
      id: id,
      name: name,
      description: description,
      thumbnailFileId: thumbnailFileId,
      updatedAt: updatedAt,
    );
  }
}

/// 動画情報モデル（設定ファイル内）
class VideoInfoModel {
  VideoInfoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoFileId,
    this.thumbnailFileId,
    required this.duration,
    required this.publishedAt,
  });

  factory VideoInfoModel.fromJson(Map<String, dynamic> json) {
    // 必須フィールドのバリデーション
    final id = json['id'] as String?;
    final title = json['title'] as String?;
    final description = json['description'] as String?;
    final videoFileId = json['video_file_id'] as String?;
    final duration = json['duration'] as int?;
    final publishedAtStr = json['published_at'] as String?;

    if (id == null || id.isEmpty) {
      throw InvalidConfigException('動画IDが見つかりません');
    }
    if (title == null || title.isEmpty) {
      throw InvalidConfigException('動画タイトルが見つかりません');
    }
    if (description == null) {
      throw InvalidConfigException('動画説明が見つかりません');
    }
    if (videoFileId == null || videoFileId.isEmpty) {
      throw InvalidConfigException('動画ファイルIDが見つかりません');
    }
    if (duration == null || duration < 0) {
      throw InvalidConfigException('動画の長さが正しくありません');
    }
    if (publishedAtStr == null) {
      throw InvalidConfigException('公開日時が見つかりません');
    }

    // 日時のパース
    DateTime publishedAt;
    try {
      publishedAt = DateTime.parse(publishedAtStr);
    } on Exception {
      throw InvalidConfigException('公開日時の形式が正しくありません: $publishedAtStr');
    }

    return VideoInfoModel(
      id: id,
      title: title,
      description: description,
      videoFileId: videoFileId,
      thumbnailFileId: json['thumbnail_file_id'] as String?,
      duration: duration,
      publishedAt: publishedAt,
    );
  }

  final String id;
  final String title;
  final String description;
  final String videoFileId;
  final String? thumbnailFileId;
  final int duration;
  final DateTime publishedAt;

  VideoInfo toEntity() {
    return VideoInfo(
      id: id,
      title: title,
      description: description,
      videoFileId: videoFileId,
      thumbnailFileId: thumbnailFileId,
      duration: duration,
      publishedAt: publishedAt,
    );
  }
}
